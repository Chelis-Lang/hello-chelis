# Toolchain Conformance Specification

## Purpose

Define the exact compiler closure, generated conformance ownership, executable
evidence, blocking CI, and learner-facing compatibility contract for this shell.

## Requirements

### Requirement: Exact Chelis 0.16.1 toolchain closure

The repository SHALL pin Chelis exactly to `=0.16.1` and SHALL use a dependency closure whose published Reef packages declare compatibility with Chelis `0.16.1`. Docker defaults, Compose image tags, workflow audit mirrors, installers, and the resolved lockfile MUST agree with that exact pin; the updated corpus SHALL NOT claim support for `0.16.0` or `0.14.0`.

#### Scenario: Fresh-clone pin resolution

- **WHEN** an authenticated user builds the repository from a fresh clone
- **THEN** the release-tarball image reports `chelis 0.16.1` and installs the `0.16.1`-compatible dependency closure, including Coral `0.7.31` and Nautilus `0.7.34`

#### Scenario: Version-drift rejection

- **WHEN** any Reef pin, Docker default, Compose tag, workflow mirror, installer selection, or lockfile compiler declaration differs from `0.16.1`
- **THEN** the offline pin-consistency or conformance guard fails before the image acceptance jobs can pass

### Requirement: Toolchain-owned shell conformance

The repository SHALL satisfy every MUST-tier row reported by Chelis `0.16.1` `reef conform audit`. Managed guidance blocks and shared skills MUST be materialized from the pinned toolchain, stamped for `0.16.1`, and kept distinct from repository-owned learner guidance and declared local skill content.

#### Scenario: Fresh-clone conformance audit

- **WHEN** `chelis reef conform audit --explain` runs in a fresh checkout with the pinned toolchain installed
- **THEN** it exits zero with no MUST-tier failure and identifies all managed artifacts as current for `0.16.1`

#### Scenario: Managed content drifts

- **WHEN** a managed block or shared skill differs from the embedded `0.16.1` content outside an allowed local extension
- **THEN** conformance audit fails and directs the maintainer to synchronize from the toolchain rather than preserve a local fork

### Requirement: Evidence-based de-narrowing

Every version-sensitive workaround or upstream limitation carried by the corpus SHALL be re-probed on `0.16.1` for each relevant command surface. Resolved behavior SHALL be de-narrowed and archived; surviving behavior SHALL have a source citation, a documented per-verb result, and an executable blocked probe when the behavior is expressible.

#### Scenario: Fixed behavior is detected

- **WHEN** a previously blocked probe passes on all command surfaces required by its documented contract
- **THEN** the obsolete workaround is removed, affected generated artifacts are regenerated from source, and the upstream entry is moved to an archived/resolved section

#### Scenario: Expected-failure behavior remains

- **WHEN** a known upstream blocker still reproduces on `0.16.1`
- **THEN** `chelis test --expect blocked` recognizes its expected diagnostic and `docs/UPSTREAM_BUGS.md` records the exact per-verb result, workaround, and re-probe trigger

#### Scenario: Blocked diagnostic drifts

- **WHEN** a blocked probe fails with an unrecognized diagnostic or changes verdict without meeting its expected contract
- **THEN** the acceptance gate fails and the citation is investigated before being updated or carried forward

### Requirement: Durable negative contracts

The repository SHALL expose must-reject language examples through the toolchain-native `tests_neg/` convention while preserving their learner-facing role. Every negative case MUST include an expected diagnostic sidecar, and acceptance MUST prove both rejection and diagnostic stability.

#### Scenario: Expected-failure negative suite

- **WHEN** `chelis test --expect neg` runs against the `tests_neg/` corpus
- **THEN** every case is rejected for its declared reason and the command exits zero

#### Scenario: Invalid program starts passing

- **WHEN** a must-reject example is accepted or fails for an unrelated diagnostic
- **THEN** the negative suite fails and the curriculum MUST NOT continue presenting the stale contract as verified behavior

### Requirement: Blocking conformance CI

Pull-request CI SHALL check out sufficient history to resolve `origin/main`, install the exact Reef-pinned private toolchain through an authenticated pin-resolving path, and run the offline pin guard, `chelis reef conform audit --explain`, and `chelis reef conform bump-check --base origin/main`. All expensive image and corpus acceptance jobs MUST depend on this guard.

#### Scenario: Pin-only pull request

- **WHEN** a pull request changes a toolchain pin without the required managed restamp, workflow mirrors, or de-narrowing evidence
- **THEN** `conform bump-check` fails and dependent acceptance jobs cannot make the pull request green

#### Scenario: Full-history comparison

- **WHEN** the conformance guard runs for a pull request
- **THEN** checkout uses full history and `origin/main` resolves for the bump comparison

### Requirement: Release-image learner acceptance

A fresh Docker image built from the authenticated Chelis release tarball SHALL be the authoritative runtime boundary for the repository. The blocking acceptance oracle SHALL verify formatting/linting, Reef build or frontend checks, native tests, negative and applicable blocked suites, generated Deep drift, C-backend golden execution, Octant round trips, c-earchin proof checks, and fallback Python tests before the bump is accepted.

#### Scenario: Fresh-clone acceptance

- **WHEN** the authoritative `.github/workflows/ci.yml` path builds the image and runs the complete gate from a fresh checkout
- **THEN** every executable example and verification lane passes on Chelis `0.16.1` with the resolved shell packages

#### Scenario: Illustrative artifact without executable evidence

- **WHEN** a README, curriculum statement, generated Deep file, or other illustrative artifact claims `0.16.1` behavior that no required executable lane verifies
- **THEN** the change is incomplete until the claim is linked to an existing executable oracle or new acceptance evidence

### Requirement: Accurate learner-facing compatibility documentation

README, curriculum, shell references, capability surface, discrepancy tracking, and upstream-bug documentation SHALL describe the accepted `0.16.1` toolchain, dependency closure, execution-lane limitations, and current test evidence without stale `0.14.0` or older version claims.

#### Scenario: Version-sensitive documentation review

- **WHEN** implementation completes its `0.16.1` probes and acceptance runs
- **THEN** learner-facing version claims, `@pin`/`@upstream` dispositions, pass counts, caveats, and installation commands match the observed repository state

#### Scenario: Documentation version drift

- **WHEN** a tracked learner document names an obsolete compiler/dependency version or a retired limitation as current
- **THEN** documentation or conformance validation fails, or the review blocks completion with the stale claim identified
