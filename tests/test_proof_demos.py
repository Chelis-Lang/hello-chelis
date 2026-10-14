"""Execute contextual demos and check their authored proof obligations.

Pytest owns the SMT and execution lane. Run this file as a script with a
verified CHELIS_BEACON_BIN for the explicit certified interval lane.
"""

from __future__ import annotations

import hashlib
import json
import math
import os
from pathlib import Path
import re
import struct
import subprocess

import pytest


ROOT = Path(__file__).resolve().parent.parent


def claim(params: str, guards: str, body: str) -> str:
    return f"forall({params}) where {guards}: {body}" if guards else body


# Independent expected obligations include the complete domains and bodies.
# A same-name tautology or narrower input box must not satisfy this gate.
SMT_GOALS = {
    **{
        "smt_uniform_payout_"
        + side: claim(
            "threshold: f32, lo: f32, hi: f32, payout: f32",
            "hi > lo, payout >= 0.0f32",
            f"(uniform_payout(threshold, lo, hi, payout) {comparison})",
        )
        for side, comparison in (("lower", ">= 0.0f32"), ("upper", "<= payout"))
    },
    **{
        "smt_" + name: claim("t: f32", "t >= 0.0f32, t <= 1.0f32", f"({body})")
        for name, body in {
            "allocation_lower": "allocation_weight(t) >= 0.25f32",
            "allocation_upper": "allocation_weight(t) <= 0.75f32",
        }.items()
    },
    **{
        "smt_spend_"
        + side: claim(
            "weight: f32",
            "weight >= 0.25f32, weight <= 0.75f32",
            f"(spend_from_weight(weight) {comparison})",
        )
        for side, comparison in (("lower", ">= 250.0f32"), ("upper", "<= 750.0f32"))
    },
    "smt_coupon_raises_mark": claim(
        "c1: f32, c2: f32, y: f32",
        "c1 >= 0.0f32, c2 > c1, y >= 0.0f32",
        "(bond_mark(c2, y) > bond_mark(c1, y))",
    ),
    **{
        "smt_"
        + name: claim(
            "mark: f32, h: f32",
            "mark >= 0.0f32, h >= 0.0f32, h <= 1.0f32",
            f"({body})",
        )
        for name, body in {
            "residual_lower": "unsecured_exposure(mark, h) >= 0.0f32",
            "residual_upper": "unsecured_exposure(mark, h) <= mark",
            "capital_within_policy": "capital_buffer(mark, h) <= (0.125f32 * mark)",
        }.items()
    },
    "smt_haircut_raises_residual": claim(
        "mark: f32, h1: f32, h2: f32",
        "mark >= 0.0f32, h1 >= 0.0f32, h1 <= h2, h2 <= 1.0f32",
        "(unsecured_exposure(mark, h1) <= unsecured_exposure(mark, h2))",
    ),
    "smt_growth_raises_value": claim(
        "d: f32, r: f32, g1: f32, g2: f32",
        "d > 0.0f32, g2 > g1, r > g2",
        "(valuation(d, r, g2) > valuation(d, r, g1))",
    ),
    "smt_growth_raises_margin": claim(
        "d: f32, r: f32, g1: f32, g2: f32, price: f32",
        "d > 0.0f32, g2 > g1, r > g2",
        "(purchase_margin(d, r, g2, price) > purchase_margin(d, r, g1, price))",
    ),
    **{
        "smt_valuation_box_"
        + side: claim(
            "d: f32, r: f32, g: f32",
            "d >= 0.5f32, d <= 1.0f32, r >= 0.08f32, r <= 0.1f32, g >= 0.02f32, g <= 0.04f32",
            f"(valuation(d, r, g) {comparison})",
        )
        for side, comparison in (("lower", ">= 6.0f32"), ("upper", "<= 26.0f32"))
    },
    "smt_hedge_position_bounded": claim(
        "d: f32",
        "d >= 0.0f32, d <= 1.0f32",
        "((hedge_from_delta(d) >= 0.0f32) && (hedge_from_delta(d) <= 10.0f32))",
    ),
    "smt_vega_position_bounded": claim(
        "v: f32",
        "v >= 0.0f32, v <= 42.0f32",
        "((notional_from_vega(v) >= 0.0f32) && (notional_from_vega(v) <= 420.0f32))",
    ),
    "smt_svi_variance_nonnegative": claim(
        "a: f32, b: f32, rho: f32, m: f32, sigma: f32, k: f32",
        "b >= 0.0f32, rho > -1.0f32, rho < 1.0f32, sigma > 0.0f32, "
        "(a + ((b * sigma) * sqrt((1.0f32 - (rho * rho))))) >= 0.0f32",
        "(Shoals.VolSurface.vs_total_variance(Shoals.VolSurface.SVI { a, b, rho, m, sigma }, k) >= 0.0f32)",
    ),
}

WRONG_GOALS = {
    "counterexample_symbolic_payout_half_budget": claim(
        "x: f32",
        "x >= 0.0f32, x <= 10.0f32",
        "(uniform_payout(x, 0.0f32, 10.0f32, 1000.0f32) <= 500.0f32)",
    ),
    "counterexample_symbolic_spend_without_weight_guard": claim(
        "weight: f32", "", "(spend_from_weight(weight) <= 750.0f32)"
    ),
    "counterexample_symbolic_coupon_reverse": claim(
        "c1: f32, c2: f32, y: f32",
        "c1 >= 0.0f32, c2 > c1, y >= 0.0f32",
        "(bond_mark(c2, y) <= bond_mark(c1, y))",
    ),
    "counterexample_symbolic_haircut_reverse": claim(
        "h: f32",
        "h > 0.0f32, h <= 1.0f32",
        "(unsecured_exposure(1000.0f32, h) < unsecured_exposure(1000.0f32, 0.0f32))",
    ),
    "counterexample_symbolic_growth_without_order": claim(
        "g1: f32, g2: f32",
        "g1 >= 0.02f32, g1 <= 0.04f32, g2 >= 0.02f32, g2 <= 0.04f32",
        "(valuation(1.0f32, 0.1f32, g2) > valuation(1.0f32, 0.1f32, g1))",
    ),
    "counterexample_symbolic_hedge_half_position": claim(
        "d: f32",
        "d >= 0.0f32, d <= 1.0f32",
        "(hedge_from_delta(d) <= 5.0f32)",
    ),
    "counterexample_symbolic_vega_tight_budget": claim(
        "v: f32",
        "v >= 0.0f32, v <= 42.0f32",
        "(notional_from_vega(v) <= 400.0f32)",
    ),
    "counterexample_symbolic_svi_without_minimum": claim(
        "a: f32, b: f32, rho: f32, m: f32, sigma: f32, k: f32",
        "b >= 0.0f32, rho > -1.0f32, rho < 1.0f32, sigma > 0.0f32",
        "(Shoals.VolSurface.vs_total_variance(Shoals.VolSurface.SVI { a, b, rho, m, sigma }, k) >= 0.0f32)",
    ),
}

# name -> (file stem, module, function, variable, low, high, side, bound)
BEACON_CASES = {
    "beacon_normal_reserve_lower": (
        "probabilitybudget",
        "ProbabilityBudget",
        "normal_tail_reserve",
        "z",
        -2.0,
        2.0,
        "lower",
        0.0,
    ),
    "beacon_normal_reserve_upper": (
        "probabilitybudget",
        "ProbabilityBudget",
        "normal_tail_reserve",
        "z",
        -2.0,
        2.0,
        "upper",
        1000.0,
    ),
    "beacon_report_delta_lower": (
        "optionrisk",
        "OptionRisk",
        "report_delta",
        "s",
        96.0,
        104.0,
        "lower",
        0.0,
    ),
    "beacon_report_delta_upper": (
        "optionrisk",
        "OptionRisk",
        "report_delta",
        "s",
        96.0,
        104.0,
        "upper",
        1.0,
    ),
    "beacon_report_vega_lower": (
        "optionrisk",
        "OptionRisk",
        "report_vega",
        "s",
        96.0,
        104.0,
        "lower",
        0.0,
    ),
    "beacon_report_vega_upper": (
        "optionrisk",
        "OptionRisk",
        "report_vega",
        "s",
        96.0,
        104.0,
        "upper",
        42.0,
    ),
    "counterexample_interval_reserve_zero": (
        "probabilitybudget",
        "ProbabilityBudget",
        "normal_tail_reserve",
        "z",
        -2.0,
        2.0,
        "upper",
        0.0,
    ),
    "counterexample_interval_delta_zero": (
        "optionrisk",
        "OptionRisk",
        "report_delta",
        "s",
        96.0,
        104.0,
        "upper",
        0.0,
    ),
    "counterexample_interval_vega_zero": (
        "optionrisk",
        "OptionRisk",
        "report_vega",
        "s",
        96.0,
        104.0,
        "upper",
        0.0,
    ),
}


def run_prove(path: str, tier: str, only: str) -> list[dict]:
    result = subprocess.run(
        [
            "chelis",
            "prove",
            path,
            "--tier",
            tier,
            "--only",
            only,
            "--smt-timeout",
            "20000",
            "--json",
        ],
        cwd=ROOT,
        capture_output=True,
        text=True,
        timeout=600,
    )
    assert result.returncode == (1 if only.startswith("counterexample_") else 0), (
        result.stdout + result.stderr
    )
    return [json.loads(line) for line in result.stdout.splitlines() if line.strip()]


def validate_records(records: list[dict], goals: dict[str, str], failed: bool) -> None:
    properties = [r for r in records if r.get("kind") == "property"]
    summaries = [r for r in records if r.get("kind") == "summary"]
    assert len(summaries) == 1 and len(properties) == len(goals)
    assert {r["name"] for r in properties} == set(goals)
    summary = summaries[0]
    assert summary["errors"] == 0 and summary["unsupported"] == 0
    assert summary["total"] == len(goals)
    assert summary["failed"] == (len(goals) if failed else 0)
    assert summary["passed"] == (0 if failed else len(goals))
    for record in properties:
        assert record["goal"] == goals[record["name"]], record
        assert record["status"] == ("failed" if failed else "passed"), record
        assert record["samples"] == 0 and record["arith_model"] == "real", record
        assert record["qualifiers"] == ["real_arithmetic"], record
        if failed:
            assert record.get("counterexample"), record
        else:
            assert all(
                a["non_vacuity"]["status"] == "established"
                for a in record["assumptions"]
            ), record


def test_record_gate_rejects_changed_goal_and_missing_result() -> None:
    name = "smt_uniform_payout_lower"
    goal = SMT_GOALS[name]
    record = {
        "kind": "property",
        "name": name,
        "goal": goal,
        "status": "passed",
        "samples": 0,
        "arith_model": "real",
        "qualifiers": ["real_arithmetic"],
        "assumptions": [],
    }
    summary = {
        "kind": "summary",
        "errors": 0,
        "unsupported": 0,
        "total": 1,
        "failed": 0,
        "passed": 1,
    }
    validate_records([record, summary], {name: goal}, False)
    with pytest.raises(AssertionError):
        validate_records([{**record, "goal": "true"}, summary], {name: goal}, False)
    with pytest.raises(AssertionError):
        validate_records([summary], {name: goal}, False)


def assert_source_reachable(records: list[dict], name: str, function: str) -> None:
    graph = next(r for r in records if r.get("kind") == "summary")["dependency_graph"]
    assert graph["status"] == "complete"
    declarations = graph["declarations"]
    by_id = {d["id"]: d for d in declarations}
    assert len(by_id) == len(declarations)
    origin = [
        d["id"] for d in declarations if d["kind"] == "property" and d["name"] == name
    ]
    expected_package = {
        "Hello": "hello-chelis",
        "Nautilus": "nautilus",
        "Shoals": "shoals",
        "Economoist": "economoist",
    }[function.split(".")[0]]
    target = [
        d["id"]
        for d in declarations
        if d["kind"] == "function"
        and d["package"] == expected_package
        and f"{d['module']}.{d['name']}" == function
    ]
    assert len(origin) == len(target) == 1, (name, function)
    reached, pending = set(), origin.copy()
    while pending:
        current = pending.pop()
        if current not in reached:
            reached.add(current)
            pending.extend(e["to"] for e in graph["edges"] if e["from"] == current)
    assert target[0] in reached, (name, function)


SMT_FILES = {
    "probabilitybudget": {"smt_uniform_payout_lower", "smt_uniform_payout_upper"},
    "curvebudget": {
        "smt_allocation_lower",
        "smt_allocation_upper",
        "smt_spend_lower",
        "smt_spend_upper",
    },
    "collateralbudget": {
        "smt_coupon_raises_mark",
        "smt_residual_lower",
        "smt_residual_upper",
        "smt_haircut_raises_residual",
        "smt_capital_within_policy",
    },
    "growthscreen": {
        "smt_growth_raises_value",
        "smt_growth_raises_margin",
        "smt_valuation_box_lower",
        "smt_valuation_box_upper",
    },
    "optionrisk": {"smt_hedge_position_bounded", "smt_vega_position_bounded"},
    "volatilityscreen": {"smt_svi_variance_nonnegative"},
}


@pytest.mark.parametrize("stem,names", SMT_FILES.items())
def test_contextual_smt_properties(stem: str, names: set[str]) -> None:
    records = run_prove(f"examples/proofdemos/{stem}.ch", "smt-only", "smt_")
    validate_records(records, {name: SMT_GOALS[name] for name in names}, False)
    for record in records:
        if record.get("kind") == "property":
            assert record["source"]["file"] == f"examples/proofdemos/{stem}.ch"
            assert record["proof_tier"] == "smt"
            assert record["composite_verdict"] == "proven_modulo_real_arithmetic"
    for name in names:
        if "uniform_payout" in name:
            target = "Nautilus.Distributions.uniform_cdf"
        elif "spend" in name:
            target = "Hello.Examples.Proofdemos.CurveBudget.spend_from_weight"
        elif "allocation" in name:
            target = "Nautilus.Interpolation.cubic_hermite"
        elif "coupon" in name:
            target = "Shoals.FixedIncome.fi_bond2"
        elif "residual" in name or "capital" in name:
            target = "Shoals.Csa.csa_collateralized_exposure"
        elif "growth" in name or "valuation" in name:
            target = "Economoist.Growth.gordon_pv"
        elif "svi" in name:
            target = "Shoals.VolSurface.vs_total_variance"
        else:
            target = "Hello.Examples.Proofdemos.OptionRisk." + (
                "hedge_from_delta" if "hedge" in name else "notional_from_vega"
            )
        assert_source_reachable(records, name, target)


COUNTEREXAMPLE_FILES = {
    "probabilitybudget": {"counterexample_symbolic_payout_half_budget"},
    "curvebudget": {"counterexample_symbolic_spend_without_weight_guard"},
    "collateralbudget": {
        "counterexample_symbolic_coupon_reverse",
        "counterexample_symbolic_haircut_reverse",
    },
    "growthscreen": {"counterexample_symbolic_growth_without_order"},
    "optionrisk": {
        "counterexample_symbolic_hedge_half_position",
        "counterexample_symbolic_vega_tight_budget",
    },
    "volatilityscreen": {"counterexample_symbolic_svi_without_minimum"},
}


@pytest.mark.parametrize("stem,names", COUNTEREXAMPLE_FILES.items())
def test_contextual_smt_counterexamples(stem: str, names: set[str]) -> None:
    # Restrict the tier too: the numerical false claims use Beacon separately.
    records = run_prove(
        f"examples/proofdemos/{stem}.ch", "smt-only", "counterexample_symbolic_"
    )
    validate_records(records, {name: WRONG_GOALS[name] for name in names}, True)
    assert all(
        r["proof_tier"] == "smt"
        and r["source"]["file"] == f"examples/proofdemos/{stem}.ch"
        for r in records
        if r.get("kind") == "property"
    )


@pytest.mark.parametrize(
    "stem,label,expected",
    [
        ("probabilitybudget", "payout_expectations", (800.0, 200.0, 158.65525)),
        ("curvebudget", "checkpoint_spending", (250.0, 328.125, 750.0)),
        ("collateralbudget", "collateral", (1018.5941, 233.71882, 29.214853)),
        ("growthscreen", "growth_scenarios", (16.666668, 25.0, 2.0)),
        ("optionrisk", "option_risk_at_100", (10.4506, 6.3683, 375.24)),
        ("volatilityscreen", "slice_volatilities", (0.1853649, 0.17320508, 0.17424417)),
    ],
)
def test_runnable_demo(stem: str, label: str, expected: tuple[float, ...]) -> None:
    result = subprocess.run(
        ["chelis", "eval", "--file", f"examples/proofdemos/{stem}.ch"],
        cwd=ROOT,
        capture_output=True,
        text=True,
        timeout=300,
    )
    assert result.returncode == 0, result.stdout + result.stderr
    outputs = dict(
        line.split(" = ", 1) for line in result.stdout.splitlines() if " = " in line
    )
    actual = tuple(float(outputs[f"{label}.{i}"]) for i in range(3))
    assert actual == pytest.approx(expected, rel=0.001, abs=0.0001)
    if stem in {"curvebudget", "growthscreen", "optionrisk", "volatilityscreen"}:
        assert "None" in outputs.values(), result.stdout


def assert_cover(certificate: dict, variable: str, low: float, high: float) -> None:
    assert certificate["method"] == "arb_box_cover_v1"
    leaves = certificate["leaves"]
    assert leaves and certificate["leaves_certified"] == len(leaves)
    assert certificate["leaves_unresolved"] == 0
    intervals = []
    for leaf in leaves:
        assert set(leaf["inputs"]) == {variable}
        lo, hi = (leaf["inputs"][variable][k] for k in ("lo", "hi"))
        a, b = (leaf["bound"][k] for k in ("lo", "hi"))
        assert all(type(v) in (int, float) and math.isfinite(v) for v in (lo, hi, a, b))
        assert low <= lo <= hi <= high and a <= b < 0.0
        intervals.append((lo, hi))
    covered = low
    for lo, hi in sorted(intervals):
        assert lo <= covered
        covered = max(covered, hi)
    assert covered == high


def test_cover_rejects_gap_or_non_strict_bound() -> None:
    def certificate(lo: float = -2.0, bound: float = -0.1) -> dict:
        return {
            "method": "arb_box_cover_v1",
            "leaves_certified": 1,
            "leaves_unresolved": 0,
            "leaves": [
                {
                    "inputs": {"z": {"lo": lo, "hi": 2.0}},
                    "bound": {"lo": -1.0, "hi": bound},
                }
            ],
        }

    assert_cover(certificate(), "z", -2.0, 2.0)
    for changed in (certificate(-1.0), certificate(bound=0.0)):
        with pytest.raises(AssertionError):
            assert_cover(changed, "z", -2.0, 2.0)


def run_beacon_gate() -> None:
    engine_path = Path(os.environ["CHELIS_BEACON_BIN"])
    engine_sha256 = hashlib.sha256(engine_path.read_bytes()).hexdigest()
    for path, failed in (
        ("examples/proofdemos/probabilitybudget.ch", False),
        ("examples/proofdemos/optionrisk.ch", False),
        ("examples/proofdemos/probabilitybudget.ch", True),
        ("examples/proofdemos/optionrisk.ch", True),
    ):
        records = run_prove(
            path, "beacon-only", "counterexample_interval_" if failed else "beacon_"
        )
        goals = {}
        for name, (stem, _, fn, var, low, high, side, bound) in BEACON_CASES.items():
            if name.startswith("counterexample_") != failed:
                continue
            if Path(path).stem != stem:
                continue
            target = fn
            comparison = ">=" if side == "lower" else "<="
            goals[name] = claim(
                f"{var}: f32",
                f"{var} >= {low}f32, {var} <= {high}f32",
                f"({target}({var}) {comparison} {bound}f32)",
            )
        validate_records(records, goals, failed)
        for record in records:
            if record.get("kind") != "property":
                continue
            stem, module, fn, var, low, high, side, bound = BEACON_CASES[record["name"]]
            assert record["proof_tier"] == "beacon"
            assert record["source"]["file"] == path
            evidence = record["engine_evidence"]
            engine = evidence["beacon_evidence"]
            assert evidence["engine_binary_sha256"] == engine_sha256
            assert evidence["input_box"] == {var: {"lo": low, "hi": high}}
            assert (
                evidence["source_dtype"] == "f32"
                and evidence["proof_graph_dtype"] == "f64"
            )
            assert evidence["float_execution_covered"] is False
            assert evidence["bound_side"] == side
            assert evidence["source_bound"] == {
                "dtype": "f64",
                "bits": struct.pack(">d", bound).hex(),
            }
            for key in ("graph_sha256", "request_sha256"):
                assert re.fullmatch("[0-9a-f]{64}", evidence[key])
            assert_source_reachable(
                records, record["name"], f"Hello.Examples.Proofdemos.{module}.{fn}"
            )
            assert_source_reachable(
                records, record["name"], "Nautilus.Distributions.normal_cdf"
            )
            if module == "OptionRisk":
                greek = "delta" if "delta" in fn else "vega"
                assert_source_reachable(
                    records, record["name"], "Hello.Capstone.BlackScholes." + greek
                )
                assert_source_reachable(
                    records, record["name"], "Hello.Capstone.BlackScholes.call_price"
                )
            assert engine["schema_version"] == "beacon.scalar_upper_bound.v1"
            if failed:
                witness = record["counterexample"]
                assert (
                    engine["verdict"] == "failed"
                    and engine["counterexample"] == witness
                )
                assert witness["method"] == "arb_point_256"
                assert (
                    low
                    <= witness["inputs"][var]["lo"]
                    == witness["inputs"][var]["hi"]
                    <= high
                )
                assert 0.0 < witness["bound"]["lo"] <= witness["bound"]["hi"]
            else:
                assert engine["verdict"] == "certified"
                assert_cover(engine["certificate"], var, low, high)
        print(
            f"{path}: {len(goals)} {'refuted' if failed else 'certified'}, no unknowns"
        )


if __name__ == "__main__":
    run_beacon_gate()
