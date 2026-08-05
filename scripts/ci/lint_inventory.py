#!/usr/bin/env python3
"""Run Chelis lint on the closed repository inventory."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

REPOSITORY_ROOT = Path(__file__).resolve().parents[2]
LINT_TARGETS = (
    ".github",
    ".gitignore",
    "c-earchin",
    "CHANGELOG.md",
    "docker",
    "docs",
    "flake.lock",
    "flake.nix",
    "LICENSE",
    "octant",
    "pyproject.toml",
    "README.md",
    "reef.lock",
    "reef.toml",
    "scripts/ci/lint_inventory.py",
    "scripts/regen_deep.py",
    "scripts/regen_octant.py",
    "src",
    "tests",
    "verify",
)
REQUIRED_ROOT_ENTRIES = frozenset(Path(target).parts[0] for target in LINT_TARGETS)
OPTIONAL_ROOT_ENTRIES = frozenset(
    {
        ".git",
        ".ci-central-helper",
        ".ci-container-artifacts",
        ".pytest_cache",
        ".ruff_cache",
    }
)
REQUIRED_SCRIPT_ENTRIES = frozenset(
    {
        "ci",
        "ci/domain_checks.sh",
        "ci/lint_inventory.py",
        "regen_deep.py",
        "regen_octant.py",
    }
)


class LintInventoryError(ValueError):
    """The repository does not match the closed lint inventory."""


def parse_lint_inventory(
    root_entries: frozenset[str], script_entries: frozenset[str]
) -> tuple[str, ...]:
    """Parse repository entries into the fixed Chelis lint targets."""
    missing_roots = REQUIRED_ROOT_ENTRIES - root_entries
    unexpected_roots = root_entries - REQUIRED_ROOT_ENTRIES - OPTIONAL_ROOT_ENTRIES
    missing_scripts = REQUIRED_SCRIPT_ENTRIES - script_entries
    unexpected_scripts = script_entries - REQUIRED_SCRIPT_ENTRIES
    if missing_roots or unexpected_roots or missing_scripts or unexpected_scripts:
        details = (
            f"missing roots={sorted(missing_roots)!r}, "
            f"unexpected roots={sorted(unexpected_roots)!r}, "
            f"missing scripts={sorted(missing_scripts)!r}, "
            f"unexpected scripts={sorted(unexpected_scripts)!r}"
        )
        raise LintInventoryError(f"lint inventory mismatch: {details}")
    return LINT_TARGETS


def lint_targets(root: Path = REPOSITORY_ROOT) -> tuple[str, ...]:
    """Read and parse the repository lint inventory."""
    root_entries = frozenset(entry.name for entry in root.iterdir())
    scripts_root = root / "scripts"
    script_entries = frozenset(
        path.relative_to(scripts_root).as_posix()
        for path in scripts_root.rglob("*")
        if "__pycache__" not in path.relative_to(scripts_root).parts
        and path.suffix != ".pyc"
    )
    return parse_lint_inventory(root_entries, script_entries)


def main() -> int:
    try:
        targets = lint_targets()
        completed = subprocess.run(
            ("chelis", "lint", "--check", *targets),
            cwd=REPOSITORY_ROOT,
            check=False,
        )
    except (LintInventoryError, OSError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 2
    return completed.returncode


if __name__ == "__main__":
    raise SystemExit(main())
