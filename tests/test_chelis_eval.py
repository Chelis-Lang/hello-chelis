"""Every example with a `def test_*() -> unit ! { Test }` runs via
`chelis test` (which the IR evaluator backs).

`chelis test` discovers nullary `def test_*()` functions and reports
pass/fail per assertion. Any non-zero exit is a failure here.
"""

from __future__ import annotations

import subprocess
from pathlib import Path

import pytest

from .conftest import all_ch_examples


@pytest.mark.parametrize("path", all_ch_examples(), ids=lambda p: str(p.name))
def test_chelis_test_passes(path: Path) -> None:
    # Skip files that don't define any test_* function — `chelis test` is a
    # no-op on those, but the empty exit is still 0, so we just run it.
    r = subprocess.run(
        ["chelis", "test", str(path)],
        check=False,
        capture_output=True,
        text=True,
    )
    assert r.returncode == 0, (
        f"chelis test {path} failed:\n"
        f"stdout:\n{r.stdout}\nstderr:\n{r.stderr}"
    )
