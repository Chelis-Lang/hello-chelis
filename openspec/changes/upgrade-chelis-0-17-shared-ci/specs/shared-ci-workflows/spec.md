## ADDED Requirements

### Requirement: CI delegates to the central consumer workflow

Each of the `ci`, `lint`, `nightly`, and `release` workflows SHALL be a thin caller
that delegates its jobs to `Chelis-Lang/ci/.github/workflows/consumer.yml`, pinned
to a reviewed full 40-character commit SHA, and SHALL select the matching closed
profile.

#### Scenario: Each workflow calls the pinned consumer workflow

- **WHEN** `.github/workflows/{ci,lint,nightly,release}.yml` are read
- **THEN** each file's single job uses
  `Chelis-Lang/ci/.github/workflows/consumer.yml@<40-hex-sha>`
- **AND** the `profile` input is `hello-chelis-ci`, `hello-chelis-lint`,
  `hello-chelis-nightly`, and `hello-chelis-release` respectively

#### Scenario: No local job bodies remain

- **WHEN** the migrated workflows are read
- **THEN** they contain no inline `runs-on`, `steps`, `docker/build-push-action`, or
  `chelis` command bodies — only event policy plus the immutable consumer call

### Requirement: Wrappers own only event policy and manifest-derived pins

Each caller wrapper SHALL retain only its own `on` triggers, `concurrency`, and
`permissions` ceiling, and SHALL pass compiler, package, and dependency pins that
match the committed `reef.toml`.

#### Scenario: Triggers and permissions preserved per workflow

- **WHEN** the migrated wrappers are read
- **THEN** `ci` and `lint` keep their push/pull_request/workflow_dispatch triggers
  with `contents: read`
- **AND** `nightly` keeps its schedule trigger, and `release` keeps its `v*` tag
  trigger with `contents: write`

#### Scenario: Passed pins match the manifest

- **WHEN** a wrapper passes `chelis-version`, and (for release) `package-version`,
  and dependency pins to the consumer workflow
- **THEN** `chelis-version` equals the `reef.toml` `package.compiler` version
  (`0.17.1`) and `package-version` equals the `reef.toml` `package.version`

### Requirement: Toolchain digest lock authenticates the pinned toolchain

The repository SHALL commit `.github/chelis-toolchains.json` in the
`chelis-toolchain-digests/v1` schema containing the reviewed `0.17.1` archive
digests, and each toolchain-installing wrapper SHALL pass a `chelis-linux-sha256`
that matches the committed lock so the central pin-consistency guard passes.

#### Scenario: Digest lock contains the pinned version

- **WHEN** `.github/chelis-toolchains.json` is read
- **THEN** its schema is `chelis-toolchain-digests/v1`
- **AND** `versions["0.17.1"]` provides both `linux-x86_64` and `darwin-arm64`
  digests in canonical `sha256:<64-lowercase-hex>` form

#### Scenario: Wrapper digest matches the committed lock

- **WHEN** a toolchain-installing wrapper passes `chelis-linux-sha256`
- **THEN** the value equals `versions["0.17.1"]["linux-x86_64"]` in the committed lock

### Requirement: Migrated wrappers pass central wrapper validation

Every migrated wrapper SHALL pass the central `consumer_profiles.py` validator for
its selected profile against the committed manifest, digest lock, and accepted
workflow SHA.

#### Scenario: consumer_profiles.py accepts each wrapper

- **WHEN** `tools/action_policy/consumer_profiles.py` is run for each wrapper with
  its `--profile`, this repo's `--manifest reef.toml`,
  `--toolchain-digests .github/chelis-toolchains.json`, and the reviewed
  `--accepted-workflow-sha`
- **THEN** the validator exits zero for all four wrappers
