## 1. Baseline and Conformance Scaffold

- [x] 1.1 Verify the deterministic `~/.chelis/toolchains/0.16.1/bin/chelis` binary, capture `reef conform audit --json` against the untouched `=0.14.0` tree, and retain the eight current MUST failures as implementation evidence.
- [x] 1.2 Run the explicit in-place retrofit `~/.chelis/toolchains/0.16.1/bin/chelis reef conform init hello-chelis --module-prefix Hello --output .` because complete required artifacts are missing; review the diff and restore any repository-specific learner intent overwritten by scaffolding.
- [x] 1.3 Classify the scaffolded managed blocks/shared skills versus repository-owned guidance, and identify any genuine local skill that must be declared through `[conform].local_skills`; do not run `conform sync` while the Reef pin is still `=0.14.0`.
- [x] 1.4 Run `openspec validate bump-chelis-0-16-1-conformance --strict --no-interactive` before compatibility implementation and resolve every planning diagnostic.

## 2. Exact Pin and Dependency Closure

- [x] 2.1 Use the direct `0.16.1` binary's mechanized `chelis reef conform bump 0.16.1` path, then verify `reef.toml` contains the exact `=0.16.1` compiler pin and all managed stamps name `0.16.1`.
- [x] 2.2 Resolve and regenerate `reef.lock` with published `0.16.1`-compatible dependencies, including Coral `0.7.31` and Nautilus `0.7.34`, and verify every lockfile compiler declaration is `=0.16.1`.
- [x] 2.3 Run post-bump `chelis reef conform sync`, confirm it is idempotent, verify every shared skill is toolchain-owned and stamped in `agent-skills/UPSTREAM.toml`, and retain only declared local skills or supported trailing overrides.
- [x] 2.4 Update `docker/Dockerfile`, `docker/docker-compose.yml`, and all CI/nightly/release build arguments or audit mirrors to `0.16.1`; prove the image downloads the matching release asset and reports `chelis 0.16.1`.
- [x] 2.5 Add or adapt an offline workflow-pin checker that discovers every toolchain-installing workflow, cover matching/missing/conflicting mirror cases, and run its focused tests.

## 3. Example Compatibility and Generated Surfaces

- [x] 3.1 Inventory source citations, README/curriculum caveats, `docs/discrepancies.md`, shell docs, and generated artifacts for version-sensitive workarounds or claims, mapping each item to its required `check`, `eval`/`test`, Reef build, and C-backend probes.
- [x] 3.2 Re-probe each mapped item inside the `0.16.1` release image; record pass/fail diagnostics per verb and classify it as fixed, partially fixed, still blocked, or drifted before editing the corpus.
- [x] 3.3 De-narrow fixes in `src/`, `tests/`, `verify/`, and Octant/c-earchin examples without adding unrelated learner features; preserve explicit compatibility code for any still-reproducing limitation.
- [x] 3.4 Regenerate every affected `.dp`, Octant span/decompile artifact, and expected output only from its authoritative source, then run the Deep and Octant drift checks byte-for-byte.
- [x] 3.5 Run focused format, lint, frontend/Reef build, native-test, and C-backend checks for each changed example area before proceeding to repository-wide fixtures.

## 4. Negative and Blocked Contracts

- [x] 4.1 Materialize the existing must-reject learner examples under the toolchain-native `tests_neg/` convention with `.expect` sidecars and an explicit single-source/synchronization rule that prevents drift from `tests/negative/`.
- [x] 4.2 Run `chelis test --expect neg`, verify every case fails for its declared diagnostic, and retain the learner-facing negative harness only where it adds distinct curriculum evidence.
- [x] 4.3 For each surviving expressible upstream blocker, add or refresh `tests_blocked/<area>/` source and expected sidecars with source citations; if no open blocker survives, verify the audit's MUST-if-blocker row remains legitimately `na`.
- [x] 4.4 Run `chelis test --expect blocked` when populated, de-narrow every FIX-detected probe, and investigate every DRIFTED diagnostic before updating an expectation.

## 5. Conformance and Learner Documentation

- [x] 5.1 Complete `AGENTS.md`, `docs/CHELIS_SURFACE.md`, `docs/UPSTREAM_BUGS.md`, and `docs/issue_drafts/README.md` around the generated managed spans, preserving repository-owned guidance outside the fences.
- [x] 5.2 Record each `0.16.1` per-verb reprobe in `docs/UPSTREAM_BUGS.md`, move resolved entries to its archived section, and refresh every capability row's `@pin`/`@upstream` disposition in `docs/CHELIS_SURFACE.md`.
- [x] 5.3 Refresh README, curriculum, getting-started, architecture, feature-matrix, shell, testing, and verification version claims, commands, caveats, dependency releases, and observed pass counts; remove stale `0.8.x`, `0.14.0`, and retired-limitation claims.
- [x] 5.4 Search all tracked text for obsolete compiler/dependency pins and unsupported compatibility claims, then reconcile every intentional historical mention with clear historical context.

## 6. Blocking CI and Release Wiring

- [x] 6.1 Add a first-stage pin/conformance job with `fetch-depth: 0`, an authenticated pin-resolving installation path, the offline workflow-pin checker, `chelis reef conform audit --explain`, and `chelis reef conform bump-check --base origin/main`.
- [x] 6.2 Make all expensive Docker, native, generated-artifact, C-backend, Octant, c-earchin, and fallback test jobs depend on the pin/conformance job so no later green can mask a failed bump contract.
- [x] 6.3 Update nightly and release workflows to use the same exact audit mirrors, derive runtime selection from `reef.toml` where practical, verify the installed binary, and retain least-privilege authenticated access to private release artifacts.
- [x] 6.4 Validate every changed workflow and pin-check fixture, including a deliberate stale-pin mutation that must fail before restoring the valid `0.16.1` state.

## 7. End-to-End Acceptance and Handoff

- [x] 7.1 Run the authoritative `.github/workflows/ci.yml` acceptance oracle from a fresh checkout: build the authenticated release-tarball image without stale cache and execute format/lint, Reef build/check, native, negative, applicable blocked, Deep drift, C-backend golden, Octant, c-earchin, and fallback Python lanes.
- [x] 7.2 Run bare pinned-toolchain `chelis reef conform audit --explain` and `chelis reef conform bump-check --base origin/main`; require zero MUST failures and a clean pin-bump verdict.
- [x] 7.3 Re-run `openspec validate bump-chelis-0-16-1-conformance --strict --no-interactive`, `git diff --check`, and a fresh adversarial review against every `toolchain-conformance` scenario; resolve valid findings and record evidence for any rejected high-severity finding.
- [x] 7.4 Check tasks only after observing their command/diff evidence, synchronize the accepted capability into baseline specs, archive the OpenSpec change through the archive workflow, and land issue #11 through a pull request rather than directly to `main`.
