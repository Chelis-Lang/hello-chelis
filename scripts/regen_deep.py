#!/usr/bin/env python3
"""Regenerate every <name>.dp file from its sibling <name>.ch via
`chelis deep`. The Deep s-expression form is the canonical machine-
facing AST — it must always match what the compiler produces, so this
script is the only mechanism that touches .dp files. They never get
hand-edited.

Usage:
    uv run scripts/regen_deep.py            # walks src/, tests/,
                                            # tests_neg/, verify/
    uv run scripts/regen_deep.py --check    # regen to a temp location,
                                            # diff against committed;
                                            # non-zero on drift

CI runs the same drift check through tests/test_surf_deep_equivalence.py,
and the release workflow runs `--check` before building Reef assets.
"""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
WALK_DIRS = ["src", "tests", "tests_neg", "verify"]


def discover() -> list[Path]:
    out: list[Path] = []
    for d in WALK_DIRS:
        for ch in sorted((REPO / d).rglob("*.ch")):
            out.append(ch)
    return out


def run_deep(ch: Path) -> str:
    r = subprocess.run(
        ["chelis", "deep", str(ch)],
        check=False, capture_output=True, text=True,
        cwd=REPO,
    )
    if r.returncode != 0:
        raise SystemExit(f"chelis deep failed for {ch}:\n{r.stdout}\n{r.stderr}")
    return r.stdout


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true",
                        help="exit nonzero on any committed-vs-regenerated drift")
    args = parser.parse_args()

    if shutil.which("chelis") is None:
        raise SystemExit("chelis not on PATH")

    drift: list[Path] = []
    for ch in discover():
        dp = ch.with_suffix(".dp")
        new = run_deep(ch)
        if args.check:
            if not dp.exists() or dp.read_text() != new:
                drift.append(dp)
        else:
            dp.write_text(new)
            print(f"  wrote {dp.relative_to(REPO)}", file=sys.stderr)

    if args.check and drift:
        print("Deep s-expressions are stale for:", file=sys.stderr)
        for p in drift:
            print(f"  {p.relative_to(REPO)}", file=sys.stderr)
        print("\nRun `uv run scripts/regen_deep.py` to regenerate.", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
