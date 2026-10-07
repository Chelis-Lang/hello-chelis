"""Every lesson in the book runs and prints the output the book shows.

The book under docs/book/src is rendered from the chelis.ch docs, which
capture each lesson with the released compiler. A lesson appears as

    `name.ch`:            then a ```chelis fence with the source,
    `chelis <command>`:   then a fence with the captured output.

Each lesson is written to its own empty directory, outside this package, and
the command is run there with the pinned toolchain. `check` lessons compare
the `kind: message` lines of the JSON report; `eval` and `deep` lessons
compare stdout. An `eval` lesson must also check clean. A difference means
the book (and so the chelis.ch page it mirrors) no longer matches the
compiler.

Package examples appear as "Save as `name.ch`" (or "Save this as"), a
```chelis-surf fence that imports this package's modules, and the next
```text fence with the `chelis eval` output. Each is written to the package root, next to
`reef.toml`, evaluated there, and removed, so a change to a module the book
quotes fails here until the book is updated.
"""

from __future__ import annotations

import json
import re
import shutil
import subprocess
from pathlib import Path

import pytest

BOOK = Path(__file__).resolve().parent.parent / "docs" / "book" / "src"
LESSON = re.compile(
    r"`([\w.]+\.ch)`:\n\n```chelis\n(.*?)\n```\n\n"
    r"`(chelis [^`]+)`:\n\n```\w+\n(.*?)\n```",
    re.S,
)

PACKAGE_EXAMPLE = re.compile(
    r"Save(?:\s+this)?\s+as\s+`([\w.]+\.ch)`[^\n]*:\n\n```chelis-surf\n(.*?)\n```"
    r"(?:\n(?!```)[^\n]*)*?\n```text\n(.*?)\n```",
    re.S,
)
PACKAGE_ROOT = BOOK.parent.parent.parent


def lessons() -> list[tuple[str, str, str, str, str]]:
    found = []
    for page in sorted(BOOK.glob("*.md")):
        for name, source, command, shown in LESSON.findall(page.read_text()):
            found.append((page.name, name, source, command, shown))
    return found


def test_book_has_lessons() -> None:
    assert lessons(), f"no lessons found under {BOOK}; did the page format change?"


def run(args: list[str], cwd: Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["chelis", *args], cwd=cwd, capture_output=True, text=True, timeout=300
    )


def report_errors(stdout: str) -> list[dict]:
    return json.loads(stdout).get("errors", [])


@pytest.mark.parametrize(
    ("page", "name", "source", "command", "shown"),
    lessons(),
    ids=[f"{p}:{n}:{c.split()[1]}" for p, n, _, c, _ in lessons()],
)
def test_lesson_output_matches_book(
    tmp_path: Path, page: str, name: str, source: str, command: str, shown: str
) -> None:
    if shutil.which("chelis") is None:
        pytest.skip("chelis not on PATH; run inside the docker image")
    (tmp_path / name).write_text(source + "\n")
    args = command.split()[1:]
    result = run(args, tmp_path)
    if args[0] == "check":
        got = "\n".join(
            f"{e['kind']}: {e['message']}" for e in report_errors(result.stdout)
        )
    else:
        assert result.returncode == 0, f"{page}: {command} failed:\n{result.stderr}"
        got = result.stdout.rstrip()
    assert got == shown.rstrip(), f"{page}: {command} output differs from the book"
    if args[0] == "eval":
        checked = run(["check", name], tmp_path)
        assert report_errors(checked.stdout) == [], f"{page}: {name} does not check"


def package_examples() -> list[tuple[str, str, str, str]]:
    found = []
    for page in sorted(BOOK.glob("*.md")):
        for name, source, shown in PACKAGE_EXAMPLE.findall(page.read_text()):
            found.append((page.name, name, source, shown))
    return found


def test_book_has_package_examples() -> None:
    assert package_examples(), "no package examples found; did the page format change?"


@pytest.mark.parametrize(
    ("page", "name", "source", "shown"),
    package_examples(),
    ids=[f"{p}:{n}" for p, n, _, _ in package_examples()],
)
def test_package_example_output_matches_book(
    page: str, name: str, source: str, shown: str
) -> None:
    if shutil.which("chelis") is None:
        pytest.skip("chelis not on PATH; run inside the docker image")
    target = PACKAGE_ROOT / f"book_example_{name}"
    assert not target.exists(), f"{target} already exists"
    target.write_text(source + "\n")
    try:
        result = run(["eval", "--file", target.name], PACKAGE_ROOT)
    finally:
        target.unlink()
    assert result.returncode == 0, f"{page}: {name} failed:\n{result.stderr}"
    assert result.stdout.rstrip() == shown.rstrip(), f"{page}: {name} differs"
