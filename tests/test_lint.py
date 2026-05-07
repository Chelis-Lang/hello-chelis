"""`chelis lint --check` must be clean across the whole repo.

This is the cross-shell nomenclature gate from spec/01-nomenclature.md
(via the chelis-lint crate). Catches `Std.IO` vs `Std.Io`, shell scripts
in a Python-only repo, ALL_CAPS module abbreviations, etc.
"""

from __future__ import annotations

import subprocess

from .conftest import REPO_ROOT


def test_lint_clean() -> None:
    r = subprocess.run(
        ["chelis", "lint", "--check", str(REPO_ROOT)],
        check=False,
        capture_output=True,
        text=True,
    )
    assert r.returncode == 0, (
        f"chelis lint reported violations:\n{r.stdout}\n{r.stderr}"
    )
