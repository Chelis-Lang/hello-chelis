"""The release workflow publishes assets for the package in reef.toml."""

from __future__ import annotations

import re
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent


def workflow_env(name: str) -> str:
    workflow = (REPO / ".github/workflows/release.yml").read_text()
    match = re.search(rf"^  {re.escape(name)}: ([^\s#]+)$", workflow, re.MULTILINE)
    assert match is not None, f"release workflow is missing {name}"
    return match.group(1)


def manifest_package_field(name: str) -> str:
    manifest = (REPO / "reef.toml").read_text()
    package = re.search(r"(?ms)^\[package\]\n(.*?)(?=^\[|\Z)", manifest)
    assert package is not None, "reef.toml is missing [package]"
    match = re.search(
        rf'^\s*{re.escape(name)}\s*=\s*"([^"]+)"', package.group(1), re.MULTILINE
    )
    assert match is not None, f"reef.toml is missing package.{name}"
    return match.group(1)


def test_release_workflow_matches_package_version() -> None:
    assert workflow_env("PACKAGE_NAME") == manifest_package_field("name")
    assert workflow_env("PACKAGE_VERSION") == manifest_package_field("version")
    assert workflow_env("CHELIS_VERSION") == manifest_package_field(
        "compiler"
    ).removeprefix("=")
