"""c-earchin finance-options proof artifacts stay executable.

The fixtures are committed from the released c-earchin finance-options
demo (pinned at v0.3.2) so hello-chelis can validate the final stack
without cloning or building c-earchin from source.
"""

from __future__ import annotations

import json
import shutil
import subprocess
from pathlib import Path

import pytest

REPO = Path(__file__).resolve().parent.parent
FIXTURES = REPO / "c-earchin" / "finance_options"


@pytest.fixture(scope="session", autouse=True)
def _chelis_on_path() -> None:
    if shutil.which("chelis") is None:
        pytest.skip("chelis not on PATH")


def test_c_earchin_finance_options_prove_passes() -> None:
    result = subprocess.run(
        [
            "chelis",
            "prove",
            str(FIXTURES / "options_rules.dp"),
            "--spans",
            str(FIXTURES / "options_rules.spans.json"),
            "--json",
        ],
        check=False,
        capture_output=True,
        text=True,
        cwd=REPO,
    )
    assert result.returncode == 0, result.stderr

    records = [json.loads(line) for line in result.stdout.splitlines() if line.strip()]
    summary = records[-1]
    # chelis 0.7.26 made the prove summary additive: it grew an
    # `obligations` field for smt-gated obligation records. The finance
    # bridge emits none, so the meaningful counts are pinned and any
    # additive key (e.g. `obligations`) is tolerated when zero.
    assert summary["kind"] == "summary"
    assert summary["errors"] == 0
    assert summary["failed"] == 0
    assert summary["passed"] == 6
    assert summary["total"] == 6
    assert summary["unsupported"] == 0
    assert summary.get("obligations", 0) == 0
    property_records = [r for r in records[:-1] if r.get("kind") == "property"]
    assert {record["name"] for record in property_records} == {
        "req_FIN_001",
        "req_FIN_002",
        "req_FIN_003",
        "req_FIN_004",
        "req_FIN_005",
        "req_FIN_006",
    }


def test_c_earchin_finance_options_failure_maps_to_ears_line() -> None:
    result = subprocess.run(
        [
            "chelis",
            "prove",
            str(FIXTURES / "options_rules_fail.dp"),
            "--spans",
            str(FIXTURES / "options_rules.spans.json"),
        ],
        check=False,
        capture_output=True,
        text=True,
        cwd=REPO,
    )
    assert result.returncode != 0
    assert "property failure: req_FIN_003" in result.stdout
    assert "options_rules.ears:3:1 FIN-003" in result.stdout
    assert (
        "WHILE the exchange is open, the portfolio delta shall be at most the limit."
        in result.stdout
    )
