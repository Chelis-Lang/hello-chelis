## ADDED Requirements

### Requirement: Single exact Chelis compiler pin

The repository SHALL target Chelis `0.17.1` as its single exact compiler version,
and every location that names the compiler version SHALL agree on `0.17.1`.

#### Scenario: Reef manifest and lock name the pinned version

- **WHEN** `reef.toml` and `reef.lock` are read
- **THEN** `package.compiler` is `"=0.17.1"` in both files
- **AND** every `compiler` / `compiler_version` field in `reef.lock` reads `0.17.1`

#### Scenario: Docker build args name the pinned version

- **WHEN** `docker/Dockerfile` and `docker/docker-compose.yml` are read
- **THEN** the `CHELIS_VERSION` build arg defaults to `0.17.1`
- **AND** the built image tag references `0.17.1`

#### Scenario: No stale 0.14.0 references remain

- **WHEN** the repository is searched for the literal `0.14.0`
- **THEN** no committed manifest, lock, Docker, or workflow file references `0.14.0`
  as the Chelis compiler version

### Requirement: Compiler-generated sidecars match the pinned compiler

All committed artifacts produced by the Chelis toolchain SHALL be regenerated
against `0.17.1` and SHALL match the pinned compiler's output byte-for-byte.

#### Scenario: Deep sidecar drift check passes

- **WHEN** `python3 scripts/regen_deep.py --check` runs inside the `0.17.1` image
- **THEN** every `.ch` source matches its committed `.dp` sidecar with no drift

#### Scenario: Octant spans regenerated

- **WHEN** the Octant `spans.json` output is regenerated with the pinned toolchain
- **THEN** the committed `spans.json` matches the regenerated output

#### Scenario: C-backend golden outputs match

- **WHEN** the supported `verify/*.ch` files are built and run through the C backend
- **THEN** their native output matches the committed `verify/expected/*` goldens

### Requirement: Corpus checks and tests pass on the pinned compiler

The corpus SHALL check, lint, and test cleanly under Chelis `0.17.1`, with any
`0.14 → 0.17` source-compatibility breakage resolved in this change.

#### Scenario: Front-end and lint gates pass

- **WHEN** `chelis check src/basics/hellotensor.ch` and `chelis lint --check .` run
  in the `0.17.1` image
- **THEN** both commands exit zero

#### Scenario: Native test suite passes

- **WHEN** `chelis test tests/ --jobs auto` runs in the `0.17.1` image
- **THEN** the full suite passes with no failures
