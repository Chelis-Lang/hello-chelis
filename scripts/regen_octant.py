"""Regenerate the octant triples (.tex -> .dp + .spans.json -> .ch) for
every .tex under octant/. Mirrors scripts/regen_deep.py for the
Surf<->Deep pairs in the rest of the repo.

Each triple is committed because the LaTeX source is the human-facing
form, the Deep output is what the compiler downstream consumes, and
the decompiled Surf is what humans see when they want to read the
translation as Chelis. CI's tests/test_octant_pairs.py runs the same
pipeline and asserts byte-equality.

Usage:
    python3 scripts/regen_octant.py
"""

from __future__ import annotations

import shutil
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
OCTANT = REPO / "octant"


def main() -> int:
    if shutil.which("octant") is None:
        raise SystemExit("octant not on PATH")
    if shutil.which("chelis") is None:
        raise SystemExit("chelis not on PATH")

    for tex in sorted(OCTANT.glob("*.tex")):
        relative_tex = tex.relative_to(REPO)
        base = tex.with_suffix("")
        dp = base.with_suffix(".dp")
        spans = base.with_suffix(".spans.json")
        ch = base.with_suffix(".ch")

        r = subprocess.run(
            [
                "octant",
                "translate",
                str(relative_tex),
                "--output",
                str(dp),
                "--spans",
                str(spans),
            ],
            check=False,
            capture_output=True,
            text=True,
            cwd=REPO,
        )
        if r.returncode != 0:
            print(f"!! octant translate failed for {tex.name}:\n{r.stderr}", file=sys.stderr)
            return 1

        s = subprocess.run(
            ["chelis", "surf", str(dp)],
            check=False, capture_output=True, text=True,
        )
        if s.returncode != 0:
            print(f"!! chelis surf failed for {dp.name}:\n{s.stderr}", file=sys.stderr)
            return 1
        ch.write_text(s.stdout)
        print(f"  wrote {dp.relative_to(REPO)}, {spans.relative_to(REPO)}, {ch.relative_to(REPO)}",
              file=sys.stderr)

    return 0


if __name__ == "__main__":
    sys.exit(main())
