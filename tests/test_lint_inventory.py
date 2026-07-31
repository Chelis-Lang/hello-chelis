from __future__ import annotations

import importlib.util
from pathlib import Path

import pytest

REPOSITORY_ROOT = Path(__file__).resolve().parent.parent
MODULE_PATH = REPOSITORY_ROOT / "scripts" / "ci" / "lint_inventory.py"
SPEC = importlib.util.spec_from_file_location("lint_inventory", MODULE_PATH)
assert SPEC is not None
assert SPEC.loader is not None
lint_inventory = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(lint_inventory)


def test_current_repository_matches_lint_inventory() -> None:
    assert lint_inventory.lint_targets(REPOSITORY_ROOT) == lint_inventory.LINT_TARGETS


def test_lint_inventory_accepts_generated_action_directories() -> None:
    root_entries = (
        lint_inventory.REQUIRED_ROOT_ENTRIES | lint_inventory.OPTIONAL_ROOT_ENTRIES
    )
    assert (
        lint_inventory.parse_lint_inventory(
            root_entries, lint_inventory.REQUIRED_SCRIPT_ENTRIES
        )
        == lint_inventory.LINT_TARGETS
    )


@pytest.mark.parametrize(
    ("root_entries", "script_entries"),
    [
        (
            lint_inventory.REQUIRED_ROOT_ENTRIES | {"unexpected"},
            lint_inventory.REQUIRED_SCRIPT_ENTRIES,
        ),
        (
            lint_inventory.REQUIRED_ROOT_ENTRIES - {"src"},
            lint_inventory.REQUIRED_SCRIPT_ENTRIES,
        ),
        (
            lint_inventory.REQUIRED_ROOT_ENTRIES,
            lint_inventory.REQUIRED_SCRIPT_ENTRIES | {"extra.py"},
        ),
        (
            lint_inventory.REQUIRED_ROOT_ENTRIES,
            lint_inventory.REQUIRED_SCRIPT_ENTRIES - {"regen_deep.py"},
        ),
    ],
)
def test_lint_inventory_rejects_root_and_script_drift(
    root_entries: frozenset[str], script_entries: frozenset[str]
) -> None:
    with pytest.raises(lint_inventory.LintInventoryError, match="inventory mismatch"):
        lint_inventory.parse_lint_inventory(root_entries, script_entries)
