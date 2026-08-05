#!/usr/bin/env bash
set -euo pipefail

python3 scripts/ci/lint_inventory.py
chelis check src/basics/hellotensor.ch
python3 scripts/regen_deep.py --check
python3 -m pytest -q tests/
