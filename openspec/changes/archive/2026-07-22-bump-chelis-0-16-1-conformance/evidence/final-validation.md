# Final validation evidence

Validated on 2026-07-22 from the `issue-11-chelis-0.16.1` worktree.

## Exact closure and image

- `scripts/check_workflow_pins.py`: PASS for all four `reef.lock` compiler
  declarations, Dockerfile, Compose, and five installer workflows.
- Pin mutation fixtures: 6 PASS (matching, missing, workflow conflict, lock
  conflict, Docker conflict, and Compose conflict).
- Authenticated Apple Container no-cache build, `linux/amd64` with Rosetta:
  PASS; image reported `chelis 0.16.1`; manifest list
  `sha256:a0d89b9964c68abe28109e4490a4b76b0d3aaf63f226d4abe7be0a173436b94c`.
- Final-context image rebuild after corpus fixes: PASS; manifest list
  `sha256:77a3593ffa01daf0ba1b8affbf59e708e049c6afc1005959f43a05b2d545e43d`.

The first combined acceptance run correctly rejected noncanonical generated
negative files and a kebab-case issue-draft filename. The synchronizer was
fixed to emit canonical source, the draft was renamed to snake_case, and CI's
format command was changed to `set -euo pipefail` plus failure-propagating
`xargs`. The repeated format/lint gate then passed.

## Acceptance lanes

| Lane | Result |
|---|---:|
| `chelis fmt --check` over source/test/negative/blocked/verify Surf | PASS |
| `chelis lint --check .` | PASS (one advisory, zero blocking errors) |
| `chelis reef build` | PASS; built `hello-chelis 0.1.11` |
| `chelis test tests/ --jobs auto` | 112 passed, 0 failed |
| `chelis test tests_neg/ --expect neg` | 3 ok, 0 failing |
| `chelis test tests_blocked/ --expect blocked` | 2 ok, 0 failing |
| `python3 scripts/regen_deep.py --check` | PASS |
| `python3 scripts/sync_negative_tests.py --check` | PASS |
| `python3 -m pytest -q tests/` | 114 passed |
| Ruff + Black over changed Python harness/scripts | PASS |

The Apple Container native run used `--cpus 8 --memory 16G`; the runtime's
low default memory killed the initial `--jobs auto` attempt before any verdict.
The explicitly resourced repeat completed all 112 positive, 3 negative, and 2
blocked cases.

## Conformance and review

- `chelis reef conform audit --explain`: PASS, zero MUST failures.
- `chelis reef conform bump-check --base origin/main`: PASS,
  `0.14.0 -> 0.16.1` with green conformance audit.
- `openspec validate --all --strict --no-interactive`: 1 passed, 0 failed.
- Changed workflow YAML parse checks: PASS.
- `git diff --check`: PASS.
- Final adversarial review: PASS, no concrete blocker or fail-open finding.

The first adversarial review's valid underlying high-severity concern was that
the fail-fast guard did not inspect lock compiler declarations. The checker and
fixtures were extended to cover lock, Docker, and Compose drift. Its medium
claim that negative/blocked suites were absent was rejected because
`.github/workflows/ci.yml` runs both explicitly behind `pin-conformance`; its
low recommendation for `contents: write` was rejected because the guard is
read-only and least privilege is required. No high-severity finding was
rejected.
