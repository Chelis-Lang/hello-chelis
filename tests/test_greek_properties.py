"""Keep certified Greek claims bound to their checked source graphs."""

from __future__ import annotations

import json
import copy
import hashlib
import math
import os
import re
import struct
import subprocess
from pathlib import Path

import pytest


ROOT = Path(__file__).resolve().parent.parent
# Audited Chelis 0.19.4 receipts over the published shell dependency graph.
# Source or compiler changes must refresh these alongside an actual Beacon run.
BEACON_FINGERPRINTS = json.loads(
    (ROOT / "tests/fixtures/blackscholes_beacon_fingerprints.json").read_text()
)
BOX = "s >= 96.0f32, s <= 104.0f32"
PARAMETERS = "s, 100.0f32, 0.05f32, 0.2f32, 1.0f32"
BOUNDS = {
    "delta_box_lower": ("delta", ">= 0.0f32"),
    "delta_box_upper": ("delta", "<= 1.0f32"),
    "vega_box_lower": ("vega", ">= 0.0f32"),
    "vega_box_upper": ("vega", "<= 42.0f32"),
}
FALSE_BOUNDS = {
    "delta_box_nonpositive_wrong": "delta",
    "vega_box_nonpositive_wrong": "vega",
}


GOALS = {
    name: f"forall(s: f32) where {BOX}: (Hello.Capstone.BlackScholes.{greek}({PARAMETERS}) {comparison})"
    for name, (greek, comparison) in BOUNDS.items()
}
GOALS.update(
    {
        name: f"forall(s: f32) where {BOX}: (Hello.Capstone.BlackScholes.{greek}({PARAMETERS}) <= 0.0f32)"
        for name, greek in FALSE_BOUNDS.items()
    }
)


def assert_goal(record: dict) -> None:
    assert record.get("goal") == GOALS[record["name"]], record


def test_greek_goal_identity_rejects_domain_and_body_drift() -> None:
    goal = (
        "forall(s: f32) where s >= 96.0f32, s <= 104.0f32: "
        "(Hello.Capstone.BlackScholes.delta(s, 100.0f32, 0.05f32, 0.2f32, 1.0f32) >= 0.0f32)"
    )
    assert_goal({"name": "delta_box_lower", "goal": goal})
    with pytest.raises(AssertionError):
        assert_goal(
            {
                "name": "delta_box_lower",
                "goal": goal.replace(": (", ", s >= 100.0f32: ("),
            }
        )
    with pytest.raises(AssertionError):
        assert_goal({"name": "delta_box_lower", "goal": goal[:-1] + " or true)"})


def assert_source_edges(records: list[dict], path: str) -> None:
    summaries = [r for r in records if r.get("kind") == "summary"]
    assert len(summaries) == 1
    graph = summaries[0].get("dependency_graph", {})
    assert graph.get("status") == "complete"
    declarations, edges = graph.get("declarations"), graph.get("edges")
    assert isinstance(declarations, list) and isinstance(edges, list)
    assert all(
        isinstance(d, dict) and isinstance(d.get("id"), str) for d in declarations
    )
    ids = [d["id"] for d in declarations]
    assert len(ids) == len(set(ids))
    assert all(
        isinstance(e, dict) and e.get("from") in ids and e.get("to") in ids
        for e in edges
    )
    pairs = {(e["from"], e["to"]) for e in edges}

    def declaration(kind: str, package: str, module: str, name: str, file: str) -> str:
        found = [
            d
            for d in declarations
            if d.get("kind") == kind
            and d.get("package") == package
            and d.get("module") == module
            and d.get("name") == name
            and d.get("source", {}).get("file") == file
        ]
        assert len(found) == 1, (module, name, found)
        return found[0]["id"]

    function_file = "src/capstone/blackscholes.ch"
    module = "Hello.Capstone.BlackScholes"
    call = declaration("function", "hello-chelis", module, "call_price", function_file)
    cdf = declaration(
        "function",
        "nautilus",
        "Nautilus.Distributions",
        "normal_cdf",
        "src/distributions.ch",
    )
    d1 = declaration("function", "hello-chelis", module, "d1", function_file)
    d2 = declaration("function", "hello-chelis", module, "d2", function_file)
    assert {(call, cdf), (call, d1), (call, d2), (d2, d1)} <= pairs
    controls = path == "proof_controls/blackscholes_greeks_wrong.ch"
    assert controls or path == "properties/blackscholes_greeks.ch"
    property_module = (
        "Hello.Proof_controls.Blackscholes_greeks_wrong"
        if controls
        else "Hello.Properties.Blackscholes_greeks"
    )
    for record in records:
        if record.get("kind") != "property":
            continue
        name = record["name"]
        greek = FALSE_BOUNDS[name] if controls else BOUNDS[name][0]
        origin = declaration("property", "hello-chelis", property_module, name, path)
        target = declaration("function", "hello-chelis", module, greek, function_file)
        assert (origin, target) in pairs and (target, call) in pairs


def assert_certified_cover(certificate: dict) -> None:
    assert certificate.get("method") == "arb_box_cover_v1"
    leaves = certificate.get("leaves")
    assert isinstance(leaves, list) and leaves
    assert type(certificate.get("leaves_certified")) is int
    assert certificate["leaves_certified"] == len(leaves)
    assert type(certificate.get("leaves_unresolved")) is int
    assert certificate["leaves_unresolved"] == 0
    intervals = []
    for leaf in leaves:
        assert isinstance(leaf, dict)
        inputs = leaf.get("inputs")
        assert isinstance(inputs, dict) and set(inputs) == {"s"}
        domain, bound = inputs["s"], leaf.get("bound")
        assert isinstance(domain, dict) and isinstance(bound, dict)
        lo, hi = domain.get("lo"), domain.get("hi")
        bound_lo, bound_hi = bound.get("lo"), bound.get("hi")
        assert all(
            type(value) in (int, float) and math.isfinite(value)
            for value in (lo, hi, bound_lo, bound_hi)
        )
        assert 96.0 <= lo <= hi <= 104.0
        assert bound_lo <= bound_hi < 0.0
        intervals.append((lo, hi))
    covered_to = 96.0
    for lo, hi in sorted(intervals):
        assert lo <= covered_to
        covered_to = max(covered_to, hi)
    assert covered_to == 104.0


def validate_beacon_records(
    records: list[dict], engine_sha256: str, controls: bool = False
) -> None:
    expected = FALSE_BOUNDS if controls else BOUNDS
    path = (
        "proof_controls/blackscholes_greeks_wrong.ch"
        if controls
        else "properties/blackscholes_greeks.ch"
    )
    properties = [r for r in records if r.get("kind") == "property"]
    assert len(records) == len(expected) + 1 and len(properties) == len(expected)
    assert {r["name"] for r in properties} == set(expected)
    assert_source_edges(records, path)
    summary = next(r for r in records if r.get("kind") == "summary")
    assert summary.get("total") == len(expected) and summary.get("errors") == 0
    assert summary.get("failed") == (len(expected) if controls else 0)
    assert summary.get("passed") == (0 if controls else len(expected))
    assert summary.get("unsupported") == 0
    assert re.fullmatch("[0-9a-f]{64}", engine_sha256)
    for record in properties:
        name = record["name"]
        fingerprint = BEACON_FINGERPRINTS[name]
        greek = FALSE_BOUNDS[name] if controls else BOUNDS[name][0]
        comparison = "<= 0.0f32" if controls else BOUNDS[name][1]
        assert_goal(record)
        assert record.get("source", {}).get("file") == path
        assert record.get("proof_tier") == "beacon" and record.get("samples") == 0
        assert record.get("arith_model") == "real"
        evidence = record.get("engine_evidence") or {}
        engine = evidence.get("beacon_evidence") or {}
        assert evidence.get("engine_binary_sha256") == engine_sha256
        assert evidence.get("input_box") == {"s": {"lo": 96.0, "hi": 104.0}}
        bound = float(comparison.split()[1].removesuffix("f32"))
        assert evidence.get("source_bound") == {
            "dtype": "f64",
            "bits": struct.pack(">d", bound).hex(),
        }
        assert evidence.get("bound_side") == (
            "lower" if comparison.startswith(">=") else "upper"
        )
        assert (
            evidence.get("source_dtype") == "f32"
            and evidence.get("proof_graph_dtype") == "f64"
        )
        assert evidence.get("float_execution_covered") is False
        source = evidence.get("source_binding") or {}
        declarations = source.get("declarations") or []
        expected_sources = {
            "Nautilus.Distributions.normal_cdf",
            *(
                "Hello.Capstone.BlackScholes." + f
                for f in ("d1", "d2", "call_price", greek)
            ),
        }
        assert len(declarations) == len(expected_sources)
        assert {d.get("name") for d in declarations} == expected_sources
        assert {d["name"]: d.get("sha256") for d in declarations} == fingerprint[
            "declarations"
        ]
        assert source.get("expression_sha256") == fingerprint["expression_sha256"]
        roots = [
            evidence.get(k)
            for k in ("source_output_root", "selected_root", "folded_root")
        ]
        assert roots == [
            fingerprint[k]
            for k in ("source_output_root", "selected_root", "folded_root")
        ]
        assert roots[1] != roots[2] and engine.get("selected_root_node_id") == roots[2]
        assert evidence.get("graph_sha256") == fingerprint["graph_sha256"]
        assert evidence.get("request_sha256") == fingerprint["request_sha256"]
        assert engine.get("dag_sha256") == fingerprint["dag_sha256"]
        assert engine.get("schema_version") == "beacon.scalar_upper_bound.v1"
        assert type(engine.get("strict_upper")) in (int, float)
        assert math.isfinite(engine["strict_upper"]) and engine["strict_upper"] == 0.0
        if controls:
            assert record.get("status") == "failed" and record.get("qualifiers") == [
                "real_arithmetic"
            ]
            assert engine.get("verdict") == "failed"
            witness = record.get("counterexample") or {}
            assert (
                witness == engine.get("counterexample")
                and witness.get("method") == "arb_point_256"
            )
            assert set(witness.get("inputs", {})) == {"s"}
            point, interval = witness["inputs"]["s"], witness.get("bound", {})
            numbers = [
                point.get("lo"),
                point.get("hi"),
                interval.get("lo"),
                interval.get("hi"),
            ]
            assert all(type(n) in (int, float) and math.isfinite(n) for n in numbers)
            assert (
                96.0 <= numbers[0] == numbers[1] <= 104.0
                and 0.0 < numbers[2] <= numbers[3]
            )
        else:
            assert record.get("status") == "passed" and record.get("qualifiers") == [
                "real_arithmetic"
            ]
            assert engine.get("verdict") == "certified"
            assert_certified_cover(engine.get("certificate") or {})


def beacon_fixture(controls: bool = False) -> list[dict]:
    names = FALSE_BOUNDS if controls else BOUNDS
    records, declarations, edges = [], [], []
    for function, package, module, file in [
        (
            "delta",
            "hello-chelis",
            "Hello.Capstone.BlackScholes",
            "src/capstone/blackscholes.ch",
        ),
        (
            "vega",
            "hello-chelis",
            "Hello.Capstone.BlackScholes",
            "src/capstone/blackscholes.ch",
        ),
        (
            "call_price",
            "hello-chelis",
            "Hello.Capstone.BlackScholes",
            "src/capstone/blackscholes.ch",
        ),
        (
            "d1",
            "hello-chelis",
            "Hello.Capstone.BlackScholes",
            "src/capstone/blackscholes.ch",
        ),
        (
            "d2",
            "hello-chelis",
            "Hello.Capstone.BlackScholes",
            "src/capstone/blackscholes.ch",
        ),
        ("normal_cdf", "nautilus", "Nautilus.Distributions", "src/distributions.ch"),
    ]:
        declarations.append(
            {
                "id": function,
                "kind": "function",
                "package": package,
                "module": module,
                "name": function,
                "source": {"file": file},
            }
        )
    edges.extend({"from": greek, "to": "call_price"} for greek in ("delta", "vega"))
    edges.append({"from": "call_price", "to": "normal_cdf"})
    edges.extend(
        {"from": source, "to": target}
        for source, target in (("call_price", "d1"), ("call_price", "d2"), ("d2", "d1"))
    )
    path = (
        "proof_controls/blackscholes_greeks_wrong.ch"
        if controls
        else "properties/blackscholes_greeks.ch"
    )
    module = (
        "Hello.Proof_controls.Blackscholes_greeks_wrong"
        if controls
        else "Hello.Properties.Blackscholes_greeks"
    )
    for name in names:
        fingerprint = BEACON_FINGERPRINTS[name]
        greek = FALSE_BOUNDS[name] if controls else BOUNDS[name][0]
        comparison = "<= 0.0f32" if controls else BOUNDS[name][1]
        witness = {
            "method": "arb_point_256",
            "inputs": {"s": {"lo": 100.0, "hi": 100.0}},
            "bound": {"lo": 0.5, "hi": 1.0},
        }
        source_names = {
            "Nautilus.Distributions.normal_cdf",
            *(
                "Hello.Capstone.BlackScholes." + f
                for f in ("d1", "d2", "call_price", greek)
            ),
        }
        engine = {
            "engine_binary_sha256": "a" * 64,
            "input_box": {"s": {"lo": 96.0, "hi": 104.0}},
            "source_bound": {
                "dtype": "f64",
                "bits": struct.pack(
                    ">d", float(comparison.split()[1].removesuffix("f32"))
                ).hex(),
            },
            "bound_side": "lower" if comparison.startswith(">=") else "upper",
            "source_dtype": "f32",
            "proof_graph_dtype": "f64",
            "float_execution_covered": False,
            "source_output_root": fingerprint["source_output_root"],
            "selected_root": fingerprint["selected_root"],
            "folded_root": fingerprint["folded_root"],
            "graph_sha256": fingerprint["graph_sha256"],
            "request_sha256": fingerprint["request_sha256"],
            "source_binding": {
                "expression_sha256": fingerprint["expression_sha256"],
                "declarations": [
                    {"name": f, "sha256": fingerprint["declarations"][f]}
                    for f in source_names
                ],
            },
            "beacon_evidence": {
                "schema_version": "beacon.scalar_upper_bound.v1",
                "selected_root_node_id": fingerprint["folded_root"],
                "dag_sha256": fingerprint["dag_sha256"],
                "strict_upper": 0.0,
                "verdict": "failed" if controls else "certified",
                "counterexample": witness if controls else None,
                "certificate": (
                    None
                    if controls
                    else {
                        "method": "arb_box_cover_v1",
                        "leaves_certified": 1,
                        "leaves_unresolved": 0,
                        "leaves": [
                            {
                                "inputs": {"s": {"lo": 96.0, "hi": 104.0}},
                                "bound": {"lo": -2.0, "hi": -1.0},
                            }
                        ],
                    }
                ),
            },
        }
        records.append(
            {
                "kind": "property",
                "name": name,
                "goal": GOALS[name],
                "source": {"file": path},
                "status": "failed" if controls else "passed",
                "proof_tier": "beacon",
                "arith_model": "real",
                "samples": 0,
                "qualifiers": ["real_arithmetic"],
                "counterexample": witness if controls else None,
                "engine_evidence": engine,
            }
        )
        declarations.append(
            {
                "id": name,
                "kind": "property",
                "package": "hello-chelis",
                "module": module,
                "name": name,
                "source": {"file": path},
            }
        )
        edges.append({"from": name, "to": greek})
    records.append(
        {
            "kind": "summary",
            "total": len(names),
            "passed": 0 if controls else len(names),
            "failed": len(names) if controls else 0,
            "unsupported": 0,
            "errors": 0,
            "dependency_graph": {
                "status": "complete",
                "declarations": declarations,
                "edges": edges,
            },
        }
    )
    return records


def test_actual_beacon_dispatch_requires_certified_bounds_and_refutes_controls() -> (
    None
):
    validate_beacon_records(beacon_fixture(), "a" * 64)
    validate_beacon_records(beacon_fixture(True), "a" * 64, controls=True)


def test_actual_beacon_dispatch_rejects_binding_and_verdict_drift() -> None:
    for field, value in [
        ("goal", "(s == s)"),
        ("status", "unsupported"),
        ("samples", 1),
        ("qualifiers", []),
    ]:
        records = beacon_fixture()
        records[0][field] = value
        with pytest.raises(AssertionError):
            validate_beacon_records(records, "a" * 64)
    for field, value in [
        ("engine_binary_sha256", "d" * 64),
        ("input_box", {"s": {"lo": 100.0, "hi": 104.0}}),
        ("folded_root", 10),
        ("float_execution_covered", True),
    ]:
        records = beacon_fixture()
        records[0]["engine_evidence"][field] = value
        with pytest.raises(AssertionError):
            validate_beacon_records(records, "a" * 64)
    records = beacon_fixture()
    records[-1]["dependency_graph"]["edges"] = []
    with pytest.raises(AssertionError):
        validate_beacon_records(records, "a" * 64)
    records = beacon_fixture()
    records[0]["engine_evidence"]["source_binding"]["declarations"].pop()
    with pytest.raises(AssertionError):
        validate_beacon_records(records, "a" * 64)
    records = beacon_fixture()
    records[0]["engine_evidence"]["beacon_evidence"]["verdict"] = "unknown"
    with pytest.raises(AssertionError):
        validate_beacon_records(records, "a" * 64)
    records = beacon_fixture(True)
    records[0]["counterexample"]["inputs"]["s"] = {"lo": 200.0, "hi": 200.0}
    with pytest.raises(AssertionError):
        validate_beacon_records(records, "a" * 64, controls=True)
    records = beacon_fixture()
    records.append(copy.deepcopy(records[0]))
    with pytest.raises(AssertionError):
        validate_beacon_records(records, "a" * 64)


def test_greek_receipts_reject_graph_and_source_fingerprint_drift() -> None:
    for controls in (False, True):
        for field, value in [
            ("source_output_root", 999999),
            ("selected_root", 999999),
            ("folded_root", 999999),
            ("graph_sha256", "f" * 64),
            ("request_sha256", "f" * 64),
        ]:
            records = beacon_fixture(controls)
            records[0]["engine_evidence"][field] = value
            with pytest.raises(AssertionError):
                validate_beacon_records(records, "a" * 64, controls)
        records = beacon_fixture(controls)
        records[0]["engine_evidence"]["beacon_evidence"]["dag_sha256"] = "f" * 64
        with pytest.raises(AssertionError):
            validate_beacon_records(records, "a" * 64, controls)
        records = beacon_fixture(controls)
        records[0]["engine_evidence"]["source_binding"]["expression_sha256"] = "f" * 64
        with pytest.raises(AssertionError):
            validate_beacon_records(records, "a" * 64, controls)
        records = beacon_fixture(controls)
        records[0]["engine_evidence"]["source_binding"]["declarations"][0]["sha256"] = (
            "f" * 64
        )
        with pytest.raises(AssertionError):
            validate_beacon_records(records, "a" * 64, controls)


def test_greek_receipts_require_complete_internal_dependency_chain() -> None:
    for controls in (False, True):
        for source, target in (
            ("call_price", "d1"),
            ("call_price", "d2"),
            ("d2", "d1"),
        ):
            records = beacon_fixture(controls)
            edges = records[-1]["dependency_graph"]["edges"]
            edges.remove({"from": source, "to": target})
            with pytest.raises(AssertionError):
                validate_beacon_records(records, "a" * 64, controls)


def test_certified_greek_receipt_requires_complete_strict_cover() -> None:
    def certified_records() -> list[dict]:
        records = beacon_fixture()
        record = records[0]
        engine = record["engine_evidence"]["beacon_evidence"]
        engine["certificate"] = {
            "method": "arb_box_cover_v1",
            "leaves_certified": 2,
            "leaves_unresolved": 0,
            "leaves": [
                {
                    "inputs": {"s": {"lo": lo, "hi": hi}},
                    "bound": {"lo": -2.0, "hi": -1.0},
                }
                for lo, hi in ((96.0, 100.0), (100.0, 104.0))
            ],
        }
        return records

    validate_beacon_records(certified_records(), "a" * 64)

    def rejects(change) -> None:
        records = certified_records()
        change(records[0]["engine_evidence"]["beacon_evidence"])
        with pytest.raises(AssertionError):
            validate_beacon_records(records, "a" * 64)

    rejects(lambda engine: engine.update(strict_upper=1000.0))

    def drop_leaf(engine) -> None:
        certificate = engine["certificate"]
        certificate["leaves"].pop()
        certificate["leaves_certified"] = 1

    rejects(drop_leaf)
    for bound in (
        {"lo": 1.0, "hi": 2.0},
        {"lo": -2.0, "hi": 0.0},
        {"lo": -2.0, "hi": float("nan")},
    ):
        rejects(lambda engine: engine["certificate"]["leaves"][0].update(bound=bound))
    for domain in (
        {"lo": 96.0, "hi": 99.0},
        {"lo": 95.0, "hi": 100.0},
        {"lo": 96.0, "hi": float("inf")},
    ):
        rejects(
            lambda engine: engine["certificate"]["leaves"][0]["inputs"].update(s=domain)
        )


def prove(path: str, tier: str, extra: list[str]) -> tuple[int, list[dict]]:
    result = subprocess.run(
        ["chelis", "prove", path, "--tier", tier, "--json", *extra],
        cwd=ROOT,
        check=False,
        capture_output=True,
        text=True,
    )
    records = [json.loads(line) for line in result.stdout.splitlines() if line.strip()]
    assert_source_edges(records, path)
    return result.returncode, [r for r in records if r.get("kind") == "property"]


def test_direct_greek_bounds_fail_closed_on_pinned_smt() -> None:
    returncode, records = prove("properties/blackscholes_greeks.ch", "smt-only", [])
    assert returncode == 2
    assert len(records) == len(BOUNDS)
    assert {r["name"] for r in records} == set(BOUNDS)
    for record in records:
        assert record["source"]["file"] == "properties/blackscholes_greeks.ch"
        assert_goal(record)
        assert record["status"] == "unsupported"
        assert record["composite_verdict"] == "unsupported"
        assert record["proof_tier"] == "smt"
        assert record["samples"] == 0
        assert record["qualifiers"] == []
        assert (
            record["reason"] == "scalar grad SMT lowering does not support call `log`"
        )


def test_false_greek_bounds_have_empirical_counterexamples() -> None:
    returncode, records = prove(
        "proof_controls/blackscholes_greeks_wrong.ch",
        "fuzz-only",
        ["--samples", "100", "--seed", "17"],
    )
    assert returncode == 1
    assert len(records) == len(FALSE_BOUNDS)
    assert {r["name"] for r in records} == set(FALSE_BOUNDS)
    for record in records:
        assert record["source"]["file"] == "proof_controls/blackscholes_greeks_wrong.ch"
        assert_goal(record)
        assert record["status"] == "failed"
        assert record["proof_tier"] == "fuzz"
        assert 96.0 <= record["counterexample"]["s"] <= 104.0


def run_beacon_gate() -> None:
    """Explicit release acceptance; ordinary corpus tests do not need Beacon."""
    engine = os.environ.get("CHELIS_BEACON_BIN")
    assert (
        engine and Path(engine).is_file()
    ), "set CHELIS_BEACON_BIN to the verified engine"
    digest = hashlib.sha256(Path(engine).read_bytes()).hexdigest()
    compiler = os.environ.get("CHELIS_BIN") or "chelis"
    for path, controls in [
        ("properties/blackscholes_greeks.ch", False),
        ("proof_controls/blackscholes_greeks_wrong.ch", True),
    ]:
        result = subprocess.run(
            [compiler, "prove", path, "--tier", "beacon-only", "--json"],
            cwd=ROOT,
            capture_output=True,
            text=True,
            timeout=120,
        )
        assert result.returncode == (1 if controls else 0), (
            result.stdout or result.stderr
        )
        records = [
            json.loads(line) for line in result.stdout.splitlines() if line.strip()
        ]
        validate_beacon_records(records, digest, controls)
        summary = next(r for r in records if r.get("kind") == "summary")
        print(
            f"{path}: {summary['passed']} certified, {summary['failed']} refuted, {summary['unsupported']} unknown"
        )


if __name__ == "__main__":
    run_beacon_gate()
