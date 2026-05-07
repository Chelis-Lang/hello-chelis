#!/usr/bin/env python3
"""Install the extant Chelis shells (coral, nautilus, octant) into the local
reef registry so they can be imported by the examples in this repo.

Two install paths, tried in order:

1. `chelis reef install --from-github <org>/<repo>@<tag>` — the canonical path
   once Reef Phase A is live in a given compiler release.
2. Git clone + `chelis reef pack` + `chelis reef install --from-archive` —
   the fallback, used when the GitHub-Releases path isn't available.

Usage:
    python3 scripts/install_shells.py            # for the current user
    python3 scripts/install_shells.py --system   # global install (used in Docker)

This script is idempotent: shells already at the pinned version are skipped.
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path


# Pinned shell versions. These match the ones in reef.toml at the root of this
# repository. Bumping any of these requires bumping the matching pin in reef.toml
# and re-running this script.
@dataclass(frozen=True)
class Shell:
    name: str
    repo: str  # github org/repo
    tag: str   # release tag


SHELLS: list[Shell] = [
    Shell(name="coral", repo="Chelis-Lang/coral", tag="v0.6.1"),
    Shell(name="nautilus", repo="Chelis-Lang/nautilus", tag="v0.6.1"),
    Shell(name="octant", repo="Chelis-Lang/octant", tag="v0.4.2"),
]


def run(cmd: list[str], *, check: bool = True, capture: bool = False) -> subprocess.CompletedProcess:
    print(f"$ {' '.join(cmd)}", flush=True)
    return subprocess.run(cmd, check=check, capture_output=capture, text=True)


def have_chelis() -> bool:
    return shutil.which("chelis") is not None


def shell_already_installed(shell: Shell) -> bool:
    """Best-effort check via `chelis reef list`. If the subcommand isn't there
    yet, treat as not-installed and let the install attempt be idempotent."""
    try:
        r = run(["chelis", "reef", "list", "--json"], check=False, capture=True)
    except FileNotFoundError:
        return False
    if r.returncode != 0:
        return False
    try:
        items = json.loads(r.stdout)
    except json.JSONDecodeError:
        return False
    expected = shell.tag.lstrip("v")
    for item in items:
        if item.get("name") == shell.name and item.get("version") == expected:
            return True
    return False


def install_from_github(shell: Shell) -> bool:
    """Try the Reef GitHub-Releases path. Returns True on success."""
    spec = f"{shell.repo}@{shell.tag}"
    r = run(
        ["chelis", "reef", "install", "--from-github", spec],
        check=False,
    )
    return r.returncode == 0


def install_from_clone(shell: Shell) -> bool:
    """Clone the shell repo at its tag, pack it, and install the archive."""
    with tempfile.TemporaryDirectory() as tmpdir:
        clone_path = Path(tmpdir) / shell.name
        run([
            "git", "clone",
            "--depth", "1",
            "--branch", shell.tag,
            f"https://github.com/{shell.repo}.git",
            str(clone_path),
        ])
        # `chelis reef pack` writes <name>-<version>.car (content-addressed
        # archive) into ./build/. We then install that archive locally.
        run(["chelis", "reef", "pack"], capture=False)  # cwd will be wrong
        # Actually run pack with cwd=clone_path:
        subprocess.run(
            ["chelis", "reef", "pack"],
            check=True,
            cwd=clone_path,
        )
        archives = list((clone_path / "build").glob(f"{shell.name}-*.car"))
        if not archives:
            print(f"!! no archive produced for {shell.name}", file=sys.stderr)
            return False
        archive = archives[0]
        r = subprocess.run(
            ["chelis", "reef", "install", "--from-archive", str(archive)],
            check=False,
        )
        return r.returncode == 0


def install_one(shell: Shell) -> None:
    if shell_already_installed(shell):
        print(f"== {shell.name} {shell.tag} already installed, skipping", flush=True)
        return
    print(f"== installing {shell.name} {shell.tag}", flush=True)
    if install_from_github(shell):
        return
    print(f"   --from-github failed; falling back to clone+pack", flush=True)
    if install_from_clone(shell):
        return
    raise SystemExit(f"failed to install {shell.name} {shell.tag}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--system",
        action="store_true",
        help="install into the system reef registry (used in the Docker image build)",
    )
    args = parser.parse_args()

    if not have_chelis():
        raise SystemExit(
            "chelis not found on PATH. Build the Docker image first with: "
            "docker compose -f docker/docker-compose.yml build"
        )

    if args.system:
        os.environ["REEF_REGISTRY"] = "/opt/chelis/registry"
        Path(os.environ["REEF_REGISTRY"]).mkdir(parents=True, exist_ok=True)

    for shell in SHELLS:
        install_one(shell)

    print("\n== all shells installed", flush=True)


if __name__ == "__main__":
    main()
