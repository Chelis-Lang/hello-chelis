"""Prove the quadratic lessons with the published compiler and false controls."""

from __future__ import annotations

import json
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent


def prove(path: str, names: set[str], expected_returncode: int) -> list[dict]:
    result = subprocess.run(
        ["chelis", "prove", path, "--tier", "smt-only", "--smt-timeout", "20000", "--json"],
        cwd=ROOT,
        check=False,
        capture_output=True,
        text=True,
    )
    assert result.returncode == expected_returncode, result.stderr or result.stdout
    records = [json.loads(line) for line in result.stdout.splitlines() if line.strip()]
    properties = [record for record in records if record.get("kind") == "property"]
    assert {record["name"] for record in properties} == names, properties
    return properties


def assert_real_smt(properties: list[dict]) -> None:
    for record in properties:
        assert record["status"] == "passed", record
        assert record["proof_tier"] == "smt", record
        assert record["composite_verdict"] == "proven_modulo_real_arithmetic", record
        assert record["qualifiers"] == ["real_arithmetic"], record
        assert record["samples"] == 0, record
        assert all(
            assumption["non_vacuity"]["status"] == "established"
            for assumption in record["assumptions"]
        ), record


def assert_counterexamples(properties: list[dict]) -> None:
    for record in properties:
        assert record["status"] == "failed", record
        assert record["proof_tier"] == "smt", record
        assert record["counterexample"], record


def test_quadratic_gradient_properties() -> None:
    assert_real_smt(prove("src/basics/quadraticdescent.ch", {
        "gradient_step_descends", "half_step_reaches_minimum",
    }, 0))
    assert_counterexamples(prove("proof_controls/quadratic_wrong.ch", {
        "unrestricted_step_descends_wrong", "half_step_exceeds_minimum_wrong",
    }, 1))


def test_parabola_properties() -> None:
    assert_real_smt(prove("src/nautilus/optimize.ch", {
        "parabola_global_minimum", "parabola_box_lower", "parabola_box_upper",
    }, 0))
    assert_counterexamples(prove("proof_controls/parabola_wrong.ch", {
        "parabola_minimum_too_high_wrong", "parabola_box_upper_too_low_wrong",
    }, 1))
