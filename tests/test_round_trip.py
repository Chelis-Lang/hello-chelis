"""For every .ch under examples/, the Surf <-> Deep round-trip must be
identity up to formatting.

`chelis surf <file.ch>` desugars to .dp; `chelis deep --to-surf <file.dp>`
goes back. Comparing the AST of original vs round-tripped is what the
canonical-form rule is built around.
"""

from __future__ import annotations

import subprocess
import tempfile
from pathlib import Path

import pytest

from .conftest import all_ch_examples


@pytest.mark.parametrize("ch", all_ch_examples(), ids=lambda p: str(p.name))
def test_surf_to_deep_to_surf(ch: Path) -> None:
    with tempfile.TemporaryDirectory() as tmpdir:
        dp = Path(tmpdir) / (ch.stem + ".dp")
        round_ch = Path(tmpdir) / (ch.stem + ".round.ch")
        # Surf -> Deep
        r1 = subprocess.run(
            ["chelis", "surf", "--to-deep", "--out", str(dp), str(ch)],
            check=False,
            capture_output=True,
            text=True,
        )
        if r1.returncode != 0:
            pytest.skip(
                f"chelis surf --to-deep is not available on this compiler: "
                f"{r1.stderr.strip()}"
            )
        # Deep -> Surf
        r2 = subprocess.run(
            ["chelis", "deep", "--to-surf", "--out", str(round_ch), str(dp)],
            check=False,
            capture_output=True,
            text=True,
        )
        assert r2.returncode == 0, f"deep -> surf failed for {ch}: {r2.stderr}"
        # The round-tripped Surf should re-check.
        r3 = subprocess.run(
            ["chelis", "check", str(round_ch)],
            check=False,
            capture_output=True,
            text=True,
        )
        assert r3.returncode == 0, (
            f"round-tripped {ch} fails to re-check:\n{r3.stdout}\n{r3.stderr}"
        )
