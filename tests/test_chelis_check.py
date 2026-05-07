"""Every .ch under examples/ must pass `chelis check`.

This is the front-end gate: parser + types + dimensions + effects +
linearity. A failure here means the example doesn't even type-check —
which is also useful, because it pins exactly which compiler version
the corpus targets.
"""

from __future__ import annotations

import json
import subprocess
from pathlib import Path

import pytest

from .conftest import all_ch_examples


@pytest.mark.parametrize("path", all_ch_examples(), ids=lambda p: str(p.name))
def test_check_passes(path: Path) -> None:
    r = subprocess.run(
        ["chelis", "check", "--json", str(path)],
        check=False,
        capture_output=True,
        text=True,
    )
    assert r.returncode == 0, (
        f"chelis check {path} failed (rc={r.returncode}):\n"
        f"stdout:\n{r.stdout}\nstderr:\n{r.stderr}"
    )
    try:
        report = json.loads(r.stdout)
    except json.JSONDecodeError as e:
        pytest.fail(f"`chelis check --json` did not emit valid JSON: {e}\n{r.stdout}")
    assert report.get("errors", []) == [], f"errors in {path}: {report['errors']}"
    assert report.get("score", 0.0) >= 0.99, f"low fitness for {path}: {report.get('score')}"
