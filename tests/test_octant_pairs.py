"""For each .tex / .ch pair under examples/05_octant/ and the capstones
that use Octant, re-run `octant translate` on the .tex and assert the
resulting Chelis matches the committed .ch byte-for-byte.

The commit is the source of truth at review time; the regenerator is the
oracle for whether the LaTeX-to-Chelis pipeline still produces it.
"""

from __future__ import annotations

import shutil
import subprocess
import tempfile
from pathlib import Path

import pytest

from .conftest import EXAMPLES


def discover_tex_pairs() -> list[tuple[Path, Path]]:
    pairs: list[tuple[Path, Path]] = []
    for tex in sorted(EXAMPLES.rglob("*.tex")):
        ch = tex.with_suffix(".ch")
        if ch.exists():
            pairs.append((tex, ch))
    return pairs


@pytest.mark.parametrize(
    "tex,ch",
    discover_tex_pairs(),
    ids=lambda p: str(p.name),
)
def test_octant_pair_byte_equal(tex: Path, ch: Path) -> None:
    if shutil.which("octant") is None:
        pytest.skip("octant not on PATH")
    with tempfile.TemporaryDirectory() as tmpdir:
        regen = Path(tmpdir) / ch.name
        r = subprocess.run(
            ["octant", "translate", str(tex), "--output", str(regen)],
            check=False,
            capture_output=True,
            text=True,
        )
        assert r.returncode == 0, (
            f"octant translate {tex} failed:\n"
            f"stdout:\n{r.stdout}\nstderr:\n{r.stderr}"
        )
        committed = ch.read_text()
        regenerated = regen.read_text()
        assert committed == regenerated, (
            f"committed {ch.relative_to(EXAMPLES)} does not match "
            f"`octant translate` output. Re-run translation and commit, "
            f"or update {tex.relative_to(EXAMPLES)}."
        )
