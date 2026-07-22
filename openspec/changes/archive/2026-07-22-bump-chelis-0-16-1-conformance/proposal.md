## Why

`hello-chelis` still builds its learner image with Chelis `=0.14.0`, while the validated dependency shells and current compiler release are available for `0.16.1`. Treating this as a de-narrowing event and adopting `chelis reef conform` keeps a fresh clone reproducible, makes stale compatibility work visible, and prevents the Docker and workflow pins from drifting again.

## What Changes

- **BREAKING**: Move the supported compiler from exact pin `=0.14.0` directly to `=0.16.1`; `0.16.0` and older toolchains are not supported by the updated corpus.
- Update `reef.toml`, `reef.lock`, Docker defaults/image tags, and every workflow pin mirror in lockstep, using the `0.16.1`-compatible shell releases (including Coral `0.7.31` and Nautilus `0.7.34`).
- Run the `0.16.1` conformance audit first, then initialize the missing shell-contract artifacts without overwriting repository-specific learner guidance. Use the mechanized `0.16.1` bump to synchronize the toolchain-owned shared skills and record their upstream stamp.
- Re-probe documented compiler/runtime discrepancies on every relevant verb, retire fixed workarounds, add conforming negative or blocked probes where required, regenerate derived Deep/Octant artifacts, and refresh version-sensitive README, curriculum, shell, surface, and upstream-bug documentation.
- Add blocking CI checks for offline pin consistency, `chelis reef conform audit`, and `chelis reef conform bump-check --base origin/main` with full checkout history.
- Rebuild the release-tarball Docker image and keep the complete learner acceptance gate green: formatting/linting, Reef build, native tests, negative and blocked suites, generated-artifact drift, C-backend goldens, Octant round trips, and c-earchin proof checks.
- Do not add new curriculum topics or intentionally change the public example API; source edits are limited to compatibility fixes, de-narrowing, and accurate documentation/evidence for `0.16.1`.

## Capabilities

### New Capabilities

- `toolchain-conformance`: Exact toolchain/dependency pinning, shell-contract artifacts, de-narrowing evidence, CI enforcement, and fresh-image acceptance for the runnable learning corpus.

### Modified Capabilities

None.

## Impact

This affects `reef.toml`, `reef.lock`, Docker configuration, all toolchain-installing workflows, CI checkout/install behavior, generated Surf/Deep and Octant artifacts when reprobes require regeneration, compatibility fixtures, learner-facing version claims, and newly materialized conformance guidance/skills/docs. The image continues to consume authenticated Chelis release artifacts rather than linking compiler crates or building the private toolchain from source. Issue #11 is delivered through a pull request, never directly to `main`.
