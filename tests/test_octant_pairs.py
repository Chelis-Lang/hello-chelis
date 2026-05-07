"""Re-run `octant translate` on each .tex and assert the regenerated .ch
matches the committed copy byte-for-byte.
"""

from __future__ import annotations

import shutil
import subprocess
import tempfile
from pathlib import Path

import pytest

from .conftest import EXAMPLES


def pairs() -> list[tuple[Path, Path]]:
    return [
        (tex, tex.with_suffix(".ch"))
        for tex in sorted(EXAMPLES.rglob("*.tex"))
        if tex.with_suffix(".ch").exists()
    ]


@pytest.mark.parametrize("tex,ch", pairs(), ids=lambda p: p.name)
def test_octant_pair_byte_equal(tex: Path, ch: Path) -> None:
    if shutil.which("octant") is None:
        pytest.skip("octant not on PATH")
    with tempfile.TemporaryDirectory() as tmpdir:
        regen = Path(tmpdir) / ch.name
        r = subprocess.run(
            ["octant", "translate", str(tex), "--output", str(regen)],
            check=False, capture_output=True, text=True,
        )
        assert r.returncode == 0, f"octant translate failed:\n{r.stderr}"
        assert ch.read_text() == regen.read_text(), (
            f"committed {ch.relative_to(EXAMPLES)} drifted from `octant translate` output"
        )
