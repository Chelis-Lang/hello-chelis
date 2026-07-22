#!/usr/bin/env python3
"""Offline consistency check for Chelis workflow mirrors and lock closure."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

PIN_RE = re.compile(r'^\s*compiler\s*=\s*"=(\d+\.\d+\.\d+)"\s*$', re.MULTILINE)
LOCK_COMPILER_RE = re.compile(r'^\s*compiler\s*=\s*"([^"]+)"\s*$', re.MULTILINE)
LOCK_SOURCE_COMPILER_RE = re.compile(
    r'^\s*compiler_version\s*=\s*"([^"]+)"\s*$', re.MULTILINE
)
MIRROR_RES = (
    re.compile(r"\bCHELIS_VERSION\s*[:=]\s*[\"']?v?(\d+\.\d+\.\d+)"),
    re.compile(r"\bCHELIS_TAG\s*[:=]\s*[\"']?v(\d+\.\d+\.\d+)"),
    re.compile(r"\bchelisup\s+install\s+[\"']?v?(\d+\.\d+\.\d+)"),
    re.compile(r"\bhello-chelis:v?(\d+\.\d+\.\d+)"),
)
PINNED_SURFACES = (Path("docker/Dockerfile"), Path("docker/docker-compose.yml"))
INSTALL_MARKERS = (
    "docker/Dockerfile",
    "chelisup install",
    "Chelis-Lang/chelis",
)


def reef_pin(root: Path) -> str:
    manifest = root / "reef.toml"
    try:
        text = manifest.read_text()
    except OSError as exc:
        raise ValueError(f"cannot read {manifest}: {exc}") from exc
    match = PIN_RE.search(text)
    if match is None:
        raise ValueError(f"{manifest}: expected exact package.compiler pin")
    return match.group(1)


def lock_status(root: Path, pin: str) -> tuple[str, list[str]]:
    lock = root / "reef.lock"
    try:
        text = lock.read_text()
    except OSError as exc:
        return "missing", [f"cannot read {lock}: {exc}"]

    compiler_values = LOCK_COMPILER_RE.findall(text)
    source_values = LOCK_SOURCE_COMPILER_RE.findall(text)
    errors: list[str] = []
    if not compiler_values:
        errors.append("reef.lock: no dependency compiler declarations found")
    invalid_compilers = sorted(
        {value for value in compiler_values if value != f"={pin}"}
    )
    if invalid_compilers:
        errors.append(
            "reef.lock: compiler declarations "
            f"[{', '.join(invalid_compilers)}] do not equal reef.toml ={pin}"
        )
    invalid_sources = sorted({value for value in source_values if value != pin})
    if invalid_sources:
        errors.append(
            "reef.lock: source compiler versions "
            f"[{', '.join(invalid_sources)}] do not equal reef.toml {pin}"
        )
    status = f"={pin} ({len(compiler_values)} dependency declarations)"
    return status, errors


def workflow_files(root: Path) -> list[Path]:
    workflow_dir = root / ".github" / "workflows"
    return sorted((*workflow_dir.glob("*.yml"), *workflow_dir.glob("*.yaml")))


def literal_mirrors(text: str) -> set[str]:
    return {
        match.group(1) for pattern in MIRROR_RES for match in pattern.finditer(text)
    }


def surface_status(root: Path, pin: str) -> tuple[list[tuple[Path, str]], list[str]]:
    surfaces: list[tuple[Path, str]] = []
    errors: list[str] = []
    for relative in PINNED_SURFACES:
        path = root / relative
        try:
            mirrors = literal_mirrors(path.read_text())
        except OSError as exc:
            surfaces.append((relative, "missing"))
            errors.append(f"cannot read {path}: {exc}")
            continue
        versions = ", ".join(sorted(mirrors))
        if mirrors != {pin}:
            surfaces.append((relative, f"conflict:{versions or 'none'}"))
            errors.append(
                f"{relative}: Chelis mirrors [{versions or 'none'}] "
                f"do not equal reef.toml ={pin}"
            )
            continue
        surfaces.append((relative, f"={pin}"))
    return surfaces, errors


def check(
    root: Path,
) -> tuple[str, str, list[tuple[Path, str]], list[tuple[Path, str]], list[str]]:
    pin = reef_pin(root)
    lock, errors = lock_status(root, pin)
    surfaces, surface_errors = surface_status(root, pin)
    errors.extend(surface_errors)
    discovered: list[tuple[Path, str]] = []

    for path in workflow_files(root):
        text = path.read_text()
        if not any(marker in text for marker in INSTALL_MARKERS):
            continue

        relative = path.relative_to(root)
        mirrors = literal_mirrors(text)
        dynamic_bump = "chelis reef conform bump" in text and "gh release view" in text
        derived = (
            "reef.toml" in text
            and "chelisup install" in text
            and re.search(r"chelisup\s+install\s+[\"']?\$", text) is not None
        )

        if dynamic_bump:
            discovered.append((relative, "dynamic-bump"))
            continue
        if derived and not mirrors:
            discovered.append((relative, "derived-from-reef.toml"))
            continue
        if not mirrors:
            discovered.append((relative, "missing"))
            errors.append(
                f"{relative}: missing literal Chelis mirror or reef.toml-derived installer"
            )
            continue
        if mirrors != {pin}:
            versions = ", ".join(sorted(mirrors))
            discovered.append((relative, f"conflict:{versions}"))
            errors.append(
                f"{relative}: Chelis mirrors [{versions}] do not equal reef.toml ={pin}"
            )
            continue
        discovered.append((relative, f"={pin}"))

    if not discovered:
        errors.append("no toolchain-installing workflows discovered")
    return pin, lock, surfaces, discovered, errors


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path.cwd())
    args = parser.parse_args(argv)

    try:
        pin, lock, surfaces, discovered, errors = check(args.root.resolve())
    except ValueError as exc:
        print(f"workflow pin check: ERROR: {exc}", file=sys.stderr)
        return 1

    print(f"reef.lock: {lock}")
    for path, disposition in surfaces:
        print(f"{path}: {disposition}")
    for path, disposition in discovered:
        print(f"{path}: {disposition}")
    if errors:
        for error in errors:
            print(f"workflow pin check: ERROR: {error}", file=sys.stderr)
        return 1
    print(f"workflow pin check: OK (={pin}; {len(discovered)} installer workflows)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
