"""The example proves its ideal-QP claim and rejects the reversed claim."""

from __future__ import annotations

import json
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def prove(path: str) -> tuple[int, list[dict]]:
    result = subprocess.run(
        ["chelis", "prove", path, "--tier", "smt-only", "--json"],
        cwd=ROOT,
        capture_output=True,
        text=True,
        timeout=300,
        check=False,
    )
    records = [json.loads(line) for line in result.stdout.splitlines() if line]
    return result.returncode, [r for r in records if r.get("kind") == "property"]


def test_calibration_proofs_are_conditional() -> None:
    code, properties = prove("properties/clarabel_calibration.ch")
    assert code == 0
    assert {p["name"] for p in properties} == {
        "optimized_step_beats_baseline",
        "interior_hedge_is_stationary",
    }
    for property_result in properties:
        assert property_result["status"] == "passed", property_result
        assert property_result["composite_verdict"] == "proven_modulo_asserted_axiom"
        assert set(property_result["qualifiers"]) == {"real_arithmetic", "axiom"}
        assert property_result["samples"] == 0
        assumption = property_result["assumptions"][0]
        assert assumption["name"] == "clarabel.qp.ideal_optimality"
        assert assumption["discharge"]["evidence"]["psd_evidence"] == "verified_gram"
        assert assumption["non_vacuity"]["status"] == "established"


def test_reversed_quality_claim_is_rejected() -> None:
    code, properties = prove("proof_controls/clarabel_reversed_quality.ch")
    assert code != 0
    assert len(properties) == 1
    assert properties[0]["status"] == "failed", properties[0]
    assert properties[0]["counterexample"]
