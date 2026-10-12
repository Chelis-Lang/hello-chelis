"""The introductory property is SMT-proved and its missing-guard control refutes."""

from __future__ import annotations

import json
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def prove(path: str) -> tuple[int, dict, dict]:
    result = subprocess.run(
        ["chelis", "prove", path, "--tier", "smt-only", "--json"],
        cwd=ROOT,
        capture_output=True,
        text=True,
        timeout=120,
        check=False,
    )
    records = [json.loads(line) for line in result.stdout.splitlines() if line]
    properties = [record for record in records if record.get("kind") == "property"]
    summaries = [record for record in records if record.get("kind") == "summary"]
    assert len(properties) == 1 and len(summaries) == 1, result.stdout + result.stderr
    return result.returncode, properties[0], summaries[0]


def test_scaled_monotonicity_is_proved_by_smt() -> None:
    code, property_result, summary = prove("src/basics/propertyproof.ch")
    assert code == 0
    assert (
        property_result["name"],
        property_result["status"],
        property_result["proof_tier"],
    ) == ("scaled_monotone", "passed", "smt")
    assert property_result["samples"] == 0
    assert property_result["qualifiers"] == ["real_arithmetic"]
    assert property_result["assumptions"][0]["non_vacuity"]["status"] == "established"
    assert (summary["total"], summary["passed"], summary["failed"]) == (1, 1, 0)


def test_missing_order_guard_has_counterexample() -> None:
    code, property_result, summary = prove("proof_controls/scaled_without_order.ch")
    assert code == 1
    assert (
        property_result["name"],
        property_result["status"],
        property_result["proof_tier"],
    ) == ("scaled_without_order", "failed", "smt")
    assert property_result["counterexample"]
    assert (summary["total"], summary["passed"], summary["failed"]) == (1, 0, 1)
