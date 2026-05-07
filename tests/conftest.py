"""Shared pytest fixtures for the hello-chelis test harness."""

from __future__ import annotations

import shutil
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parent.parent
EXAMPLES = REPO_ROOT / "examples"


@pytest.fixture(scope="session")
def repo_root() -> Path:
    return REPO_ROOT


@pytest.fixture(scope="session")
def examples_root() -> Path:
    return EXAMPLES


@pytest.fixture(scope="session", autouse=True)
def chelis_on_path() -> None:
    if shutil.which("chelis") is None:
        pytest.skip(
            "chelis not on PATH. Run inside the docker image: "
            "docker compose -f docker/docker-compose.yml run --rm hello-chelis "
            "python3 -m pytest tests/"
        )


def all_ch_examples() -> list[Path]:
    return sorted(EXAMPLES.rglob("*.ch"))


def all_tex_examples() -> list[Path]:
    return sorted(EXAMPLES.rglob("*.tex"))
