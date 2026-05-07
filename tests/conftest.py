"""Pytest fixtures. The Python harness only exists for cases where
shelling out to a non-Chelis tool is unavoidable; everything testable
in Chelis lives in `Std.Test.test_*` functions in the .ch files.
"""

from __future__ import annotations

import shutil
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parent.parent
EXAMPLES = REPO_ROOT / "examples"


@pytest.fixture(scope="session", autouse=True)
def _chelis_on_path() -> None:
    if shutil.which("chelis") is None:
        pytest.skip("chelis not on PATH; run inside the docker image")
