#!/usr/bin/env bash
set -euo pipefail

chelis lint --check .
chelis check src/basics/hellotensor.ch
python3 scripts/regen_deep.py --check
python3 -m pytest -q tests/
