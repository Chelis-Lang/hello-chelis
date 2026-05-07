"""Each .tex under octant/ is a LaTeX source. octant translates it to
canonical Deep (a .dp file with a sibling .spans.json provenance
manifest), and `chelis surf` decompiles that Deep back to readable
Chelis (.ch). All three representations of the same program are
committed; this test re-runs the pipeline and asserts byte-equality
against each committed file. Drift in any direction (LaTeX -> Deep,
Deep -> spans manifest, Deep -> Surf) is a CI failure.
"""

from __future__ import annotations

import shutil
import subprocess
import tempfile
from pathlib import Path

import pytest

REPO = Path(__file__).resolve().parent.parent
OCTANT = REPO / "octant"


def triples() -> list[Path]:
    return sorted(OCTANT.glob("*.tex"))


@pytest.fixture(scope="session", autouse=True)
def _tools_on_path() -> None:
    if shutil.which("octant") is None:
        pytest.skip("octant not on PATH")
    if shutil.which("chelis") is None:
        pytest.skip("chelis not on PATH")


@pytest.mark.parametrize("tex", triples(), ids=lambda p: p.stem)
def test_octant_triple_byte_equal(tex: Path) -> None:
    """For each .tex: re-translate to .dp + .spans.json, decompile to
    .ch, and assert all three regenerated files match what's committed.
    """
    dp = tex.with_suffix(".dp")
    spans = tex.with_suffix(".spans.json")
    ch = tex.with_suffix(".ch")
    for f in (dp, spans, ch):
        assert f.exists(), f"missing sibling {f.name} for {tex.name}"

    with tempfile.TemporaryDirectory() as tmpdir:
        rdp = Path(tmpdir) / dp.name
        rspans = Path(tmpdir) / spans.name
        rch = Path(tmpdir) / ch.name

        r = subprocess.run(
            ["octant", "translate", str(tex), "--output", str(rdp), "--spans", str(rspans)],
            check=False, capture_output=True, text=True,
        )
        assert r.returncode == 0, f"octant translate failed for {tex.name}:\n{r.stderr}"

        s = subprocess.run(
            ["chelis", "surf", str(rdp)],
            check=False, capture_output=True, text=True,
        )
        assert s.returncode == 0, f"chelis surf failed for {tex.stem}.dp:\n{s.stderr}"
        rch.write_text(s.stdout)

        for committed, regenerated in ((dp, rdp), (spans, rspans), (ch, rch)):
            # The .spans.json embeds an absolute path to the source .tex
            # which differs between the committed copy and this temp run;
            # filter that one field before comparing.
            if committed.suffix == ".json":
                import json
                a = json.loads(committed.read_text())
                b = json.loads(regenerated.read_text())
                a.pop("source", None)
                b.pop("source", None)
                assert a == b, f"{committed.name}: spans drift (excluding source path)"
            else:
                assert committed.read_text() == regenerated.read_text(), (
                    f"{committed.name} drifted from regenerated output for {tex.name}. "
                    f"Re-run `python3 scripts/regen_octant.py` to bring back into sync."
                )
