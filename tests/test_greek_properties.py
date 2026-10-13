"""Keep direct Greek claims source-bound and fail closed until provable."""

from __future__ import annotations

import json
import subprocess
from pathlib import Path

import pytest


ROOT = Path(__file__).resolve().parent.parent
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


def prove(path: str, tier: str, extra: list[str]) -> tuple[int, list[dict]]:
    result = subprocess.run(
        ["chelis", "prove", path, "--tier", tier, "--json", *extra],
        cwd=ROOT,
        check=False,
        capture_output=True,
        text=True,
    )
    records = [json.loads(line) for line in result.stdout.splitlines() if line.strip()]
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
