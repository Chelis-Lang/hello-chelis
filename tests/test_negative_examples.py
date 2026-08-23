"""Each .ch under tests_neg/check/ has a `-- chelis-expect-fail: <kind>`
header and must be REJECTED by `chelis check`. The compiler's first
reported error must carry the declared kind, and its message must
contain the substring pinned on line 1 of the sibling .expect file.

The native runner (`chelis test tests_neg --expect neg`, wired into
ci.yml) checks the message substring. This harness checks the structured
error *kind*, which the runner cannot see. Both read the same corpus.

These files are checked OUTSIDE the project root (chelis check would
otherwise treat tests_neg/ as a non-source-root within the project
and refuse to load them). We copy each to /tmp and run chelis check
there.
"""

from __future__ import annotations

import json
import re
import shutil
import subprocess
import tempfile
from pathlib import Path

import pytest

NEGATIVE_DIR = Path(__file__).resolve().parent.parent / "tests_neg" / "check"
HEADER_RE = re.compile(r"^--\s*chelis-expect-fail:\s*(\S+)", re.MULTILINE)


def discover() -> list[tuple[Path, str]]:
    out: list[tuple[Path, str]] = []
    for p in sorted(NEGATIVE_DIR.glob("*.ch")):
        m = HEADER_RE.search(p.read_text())
        if not m:
            raise AssertionError(
                f"{p.name} missing `-- chelis-expect-fail: <kind>` header"
            )
        expect = p.with_suffix(".expect")
        if not expect.exists():
            raise AssertionError(f"{p.name} missing its .expect sidecar")
        out.append((p, m.group(1)))
    return out


@pytest.mark.parametrize(
    "path,expected_kind", discover(), ids=lambda v: v.name if isinstance(v, Path) else v
)
def test_compiler_rejects(path: Path, expected_kind: str) -> None:
    if shutil.which("chelis") is None:
        pytest.skip("chelis not on PATH")
    with tempfile.TemporaryDirectory() as tmp:
        copy = Path(tmp) / path.name
        copy.write_text(path.read_text())
        r = subprocess.run(
            ["chelis", "check", str(copy), "--allow-style-violations"],
            check=False,
            capture_output=True,
            text=True,
            cwd=tmp,
        )
        try:
            report = json.loads(r.stdout)
        except json.JSONDecodeError:
            assert (
                r.returncode != 0
            ), f"{path.name}: expected failure, got rc=0\n{r.stdout}\n{r.stderr}"
            return
        errors = report.get("errors", [])
        assert errors, f"{path.name}: expected at least one error, got none"
        assert (
            errors[0].get("kind") == expected_kind
        ), f"{path.name}: expected {expected_kind}, got {errors[0].get('kind')}"
        pinned = path.with_suffix(".expect").read_text().splitlines()[0].strip()
        assert pinned in errors[0].get("message", ""), (
            f"{path.name}: first error message {errors[0].get('message')!r} "
            f"does not contain the pinned substring {pinned!r}"
        )
