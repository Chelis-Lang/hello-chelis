"""Negative tests: snippets the compiler is expected to *reject*.

These live as JSON files under tests/expected/*_should_fail.json so the
corpus under examples/ stays uniformly passable for the positive harness.
Each snippet is written to a temp file, fed to `chelis check --json`,
and the result is asserted against the JSON's `expected` block.
"""

from __future__ import annotations

import json
import subprocess
import tempfile
from pathlib import Path

import pytest

EXPECTED = Path(__file__).resolve().parent / "expected"


def discover() -> list[Path]:
    return sorted(EXPECTED.glob("*_should_fail.json"))


@pytest.mark.parametrize("p", discover(), ids=lambda p: p.stem)
def test_compiler_rejects(p: Path) -> None:
    spec = json.loads(p.read_text())
    snippet = spec["snippet"]
    expected = spec["expected"]
    with tempfile.TemporaryDirectory() as tmpdir:
        ch = Path(tmpdir) / "neg.ch"
        ch.write_text(snippet)
        r = subprocess.run(
            ["chelis", "check", "--json", str(ch)],
            check=False,
            capture_output=True,
            text=True,
        )
        if expected.get("rc_nonzero"):
            assert r.returncode != 0, (
                f"{p.name}: expected non-zero exit, got {r.returncode}\n"
                f"stdout:\n{r.stdout}"
            )
        # Best-effort error-kind assertion: the JSON report's first error
        # should carry the expected category.
        try:
            report = json.loads(r.stdout)
        except json.JSONDecodeError:
            return  # rc was non-zero; that's enough
        errs = report.get("errors", [])
        if "error_kind" in expected and errs:
            assert errs[0].get("kind") == expected["error_kind"], (
                f"{p.name}: expected error kind {expected['error_kind']}, "
                f"got {errs[0].get('kind')}"
            )
