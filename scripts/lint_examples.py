#!/usr/bin/env python3
"""Run `chelis lint --check` over the corpus.

`chelis lint` enforces the cross-shell identifier conventions recorded in
spec/01-nomenclature.md (Std.Io vs Std.IO, PascalCase modules, no shell
scripts in repos that ship with chelis tooling, etc.). On the post-v0.6.0
chelis main, this gate is expected to be clean.
"""

from __future__ import annotations

import shutil
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent


def main() -> int:
    if shutil.which("chelis") is None:
        print("chelis not on PATH; run inside the docker image", file=sys.stderr)
        return 1
    r = subprocess.run(
        ["chelis", "lint", "--check", str(REPO_ROOT)],
        check=False,
    )
    return r.returncode


if __name__ == "__main__":
    sys.exit(main())
