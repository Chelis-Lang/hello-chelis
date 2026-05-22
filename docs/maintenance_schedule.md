# Maintenance schedule

Scheduled maintenance items with hard external deadlines. Items get
removed once the corresponding work has shipped.

## GitHub Actions Node 20 -> Node 24 migration

GitHub is deprecating Node 20 as the runtime for JavaScript actions.
Until Node-24-compatible pins ship for each action we depend on, this
repo's workflows continue to run on Node 20 implicitly. Two hard dates
matter:

- **2026-06-02**: GitHub flips the default runtime to Node 24. Any
  workflow still pinned to an action version whose JS bundle targets
  Node 20 will emit a deprecation warning and (per the announcement)
  may be force-migrated. All four chelis-ecosystem repos must have
  Node-24-compatible action pins in place before this date.
- **2026-09-16**: Node 20 runtime support is removed entirely.
  Workflows still on Node-20-bundled actions stop running.

Deprecation announcement:
<https://github.blog/changelog/2025-09-15-actions-deprecating-node-20-support/>

### hello-chelis-specific migration list

This repo is the most exposed of the four chelis-ecosystem repos
because the docker-related workflows pull additional JS actions:

| Workflow | Action | Current pin | Target pin |
|---|---|---|---|
| `ci.yml` | `actions/checkout` | `@v4` | `@v4` (latest @v4 release ships Node-24 bundle; verify before deadline) |
| `ci.yml` | `docker/setup-buildx-action` | `@v3` | `@v3` (verify Node-24 bundle ships) |
| `ci.yml` | `docker/build-push-action` | `@v5` | `@v5` (verify Node-24 bundle ships) |
| `release.yml` | `actions/checkout` | `@v4` | `@v4` (same) |
| `release.yml` | `softprops/action-gh-release` | `@v2` | `@v2` (verify Node-24 bundle ships) |
| `nightly.yml` | `actions/checkout` | `@v4` | `@v4` (same) |
| `nightly.yml` | `docker/setup-buildx-action` | `@v3` | `@v3` (same) |
| `nightly.yml` | `docker/build-push-action` | `@v5` | `@v5` (same) |
| `lint.yml` | `actions/checkout` | `@v4` | `@v4` (same) |
| `lint.yml` | `docker/setup-buildx-action` | `@v3` | `@v3` (same) |
| `lint.yml` | `docker/build-push-action` | `@v5` | `@v5` (same) |

The pin bumps themselves are deferred until upstream actions publish
Node-24-compatible releases. This file exists so the deadline is not
forgotten; the corresponding tracker issue is the work item.

### Out of scope here

Non-JS-runtime actions and `actions/setup-python` (also JS-runtime;
tracked by `actions/`-org migration on its own cadence) should be
re-verified opportunistically when the JS actions above are bumped.
