"""The offline workflow-pin checker discovers and rejects pin drift."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

CHECKER = Path(__file__).resolve().parents[1] / "scripts" / "check_workflow_pins.py"


def run_checker(root: Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, str(CHECKER), "--root", str(root)],
        check=False,
        capture_output=True,
        text=True,
    )


def write_fixture(root: Path, workflow: str) -> None:
    (root / ".github" / "workflows").mkdir(parents=True)
    (root / "docker").mkdir()
    (root / "reef.toml").write_text(
        '[package]\nname = "fixture"\nversion = "0.1.0"\ncompiler = "=0.16.1"\n'
    )
    (root / "reef.lock").write_text(
        '[[dependencies]]\nname = "chelis-std"\nversion = "0.4.0"\n'
        'compiler = "=0.16.1"\n\n[dependencies.source]\nkind = "bundled"\n'
        'compiler_version = "0.16.1"\n'
    )
    (root / "docker" / "Dockerfile").write_text("ARG CHELIS_VERSION=0.16.1\n")
    (root / "docker" / "docker-compose.yml").write_text(
        "services:\n  hello-chelis:\n    image: hello-chelis:0.16.1\n"
        "    build:\n      args:\n        CHELIS_VERSION: 0.16.1\n"
    )
    (root / ".github" / "workflows" / "ci.yml").write_text(workflow)
    (root / ".github" / "workflows" / "docs.yml").write_text(
        "name: docs\njobs:\n  docs:\n    steps:\n      - run: echo docs\n"
    )


def test_matching_mirror_passes(tmp_path: Path) -> None:
    write_fixture(
        tmp_path,
        """name: ci
jobs:
  image:
    steps:
      - uses: docker/build-push-action@v5
        with:
          file: docker/Dockerfile
          build-args: |
            CHELIS_VERSION=0.16.1
""",
    )

    result = run_checker(tmp_path)

    assert result.returncode == 0, result.stderr
    assert "ci.yml: =0.16.1" in result.stdout
    assert "1 installer workflows" in result.stdout


def test_conflicting_lock_compiler_fails(tmp_path: Path) -> None:
    write_fixture(
        tmp_path,
        """name: ci
jobs:
  image:
    steps:
      - uses: docker/build-push-action@v5
        with:
          file: docker/Dockerfile
          build-args: |
            CHELIS_VERSION=0.16.1
""",
    )
    lock = tmp_path / "reef.lock"
    lock.write_text(
        lock.read_text().replace('compiler = "=0.16.1"', 'compiler = "=0.14.0"')
    )

    result = run_checker(tmp_path)

    assert result.returncode == 1
    assert "reef.lock: compiler declarations [=0.14.0]" in result.stderr


def test_conflicting_docker_default_fails(tmp_path: Path) -> None:
    write_fixture(
        tmp_path,
        """name: ci
jobs:
  image:
    steps:
      - uses: docker/build-push-action@v5
        with:
          file: docker/Dockerfile
          build-args: |
            CHELIS_VERSION=0.16.1
""",
    )
    dockerfile = tmp_path / "docker" / "Dockerfile"
    dockerfile.write_text("ARG CHELIS_VERSION=0.14.0\n")

    result = run_checker(tmp_path)

    assert result.returncode == 1
    assert "docker/Dockerfile: Chelis mirrors [0.14.0]" in result.stderr


def test_conflicting_compose_tag_fails(tmp_path: Path) -> None:
    write_fixture(
        tmp_path,
        """name: ci
jobs:
  image:
    steps:
      - uses: docker/build-push-action@v5
        with:
          file: docker/Dockerfile
          build-args: |
            CHELIS_VERSION=0.16.1
""",
    )
    compose = tmp_path / "docker" / "docker-compose.yml"
    compose.write_text(
        compose.read_text().replace("hello-chelis:0.16.1", "hello-chelis:0.14.0")
    )

    result = run_checker(tmp_path)

    assert result.returncode == 1
    assert "docker/docker-compose.yml: Chelis mirrors [0.14.0, 0.16.1]" in result.stderr


def test_missing_mirror_fails(tmp_path: Path) -> None:
    write_fixture(
        tmp_path,
        """name: ci
jobs:
  image:
    steps:
      - uses: docker/build-push-action@v5
        with:
          file: docker/Dockerfile
""",
    )

    result = run_checker(tmp_path)

    assert result.returncode == 1
    assert "missing literal Chelis mirror" in result.stderr


def test_conflicting_mirrors_fail(tmp_path: Path) -> None:
    write_fixture(
        tmp_path,
        """name: ci
env:
  CHELIS_TAG: v0.14.0
jobs:
  image:
    steps:
      - uses: docker/build-push-action@v5
        with:
          file: docker/Dockerfile
          build-args: |
            CHELIS_VERSION=0.16.1
""",
    )

    result = run_checker(tmp_path)

    assert result.returncode == 1
    assert "[0.14.0, 0.16.1] do not equal reef.toml =0.16.1" in result.stderr
