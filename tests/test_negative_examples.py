"""Each .ch under tests/negative/ has a `// chelis-expect-fail: <kind>`
header and must be REJECTED by `chelis check`. The compiler's first
reported error must carry the declared kind.

This is the only thing that needs Python: `chelis check` exits non-zero
on any malformed program, but distinguishing "wrong kind of error" from
"right kind of error" needs us to read the JSON report.
"""

from __future__ import annotations

import json
import re
import subprocess
from pathlib import Path

import pytest

NEGATIVE_DIR = Path(__file__).resolve().parent / "negative"
HEADER_RE = re.compile(r"^//\s*chelis-expect-fail:\s*(\S+)", re.MULTILINE)


def discover() -> list[tuple[Path, str]]:
    out: list[tuple[Path, str]] = []
    for p in sorted(NEGATIVE_DIR.glob("*.ch")):
        m = HEADER_RE.search(p.read_text())
        if not m:
            raise AssertionError(f"{p.name} missing `// chelis-expect-fail: <kind>` header")
        out.append((p, m.group(1)))
    return out


@pytest.mark.parametrize("path,expected_kind", discover(), ids=lambda v: v.name if isinstance(v, Path) else v)
def test_compiler_rejects(path: Path, expected_kind: str) -> None:
    r = subprocess.run(
        ["chelis", "check", "--json", str(path)],
        check=False,
        capture_output=True,
        text=True,
    )
    assert r.returncode != 0, f"{path.name}: expected failure, got rc=0"
    try:
        report = json.loads(r.stdout)
    except json.JSONDecodeError:
        return  # rc was non-zero; that's enough
    errors = report.get("errors", [])
    if errors:
        assert errors[0].get("kind") == expected_kind, (
            f"{path.name}: expected {expected_kind}, got {errors[0].get('kind')}"
        )
