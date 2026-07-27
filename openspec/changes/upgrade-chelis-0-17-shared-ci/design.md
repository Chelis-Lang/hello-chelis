## Context

hello-chelis pins Chelis `0.14.0` and ships four self-contained workflows. Each
downloads the toolchain (via a Docker build or a raw `gh release download`), runs
`chelis` gates, and re-implements a nightly-failure tracking issue. The private
`Chelis-Lang/ci` repo now centralizes exactly these mechanics behind one reusable
`consumer.yml` with a closed `profile` selector; its README already lists
`hello-chelis-ci`, `hello-chelis-lint`, `hello-chelis-nightly`, and
`hello-chelis-release` as reviewed profiles that reproduce the current jobs
(pin-consistency guard, Docker build with manifest-derived args, chelis
check/lint/test, Deep drift check, C-backend pytest, valgrind subset, and the
release asset build). A prior in-progress worktree
(`.work/node24-hello-chelis`) already migrated the wrappers for `0.14.0`, which
confirms the target shape and input set; this change re-targets that shape at
`0.17.1`.

Two independent axes are bundled because they touch the same files and must be
verified together: the compiler version pin (manifest, lock, Docker, digest lock,
regenerated sidecars) and the CI delegation (workflow wrappers + digest lock).

## Goals / Non-Goals

**Goals:**

- Pin Chelis `0.17.1` consistently and regenerate every compiler-produced sidecar
  so drift/golden checks pass on the released compiler.
- Replace the four local workflows with immutable SHA-pinned callers of
  `Chelis-Lang/ci/.github/workflows/consumer.yml`, preserving current trigger,
  concurrency, and permission behavior.
- Authenticate the toolchain by committing `0.17.1` archive digests in
  `.github/chelis-toolchains.json` and passing the matching `chelis-linux-sha256`.

**Non-Goals:**

- Changing Reef dependency pins (`coral`, `nautilus`, `school`, `octant`,
  `c-earchin`) beyond what a `0.17.1` rebuild forces.
- Changing product source behavior except for `0.14 → 0.17` compatibility fixes.
- Modifying anything inside `Chelis-Lang/ci`; this repo is a consumer only.

## Decisions

- **Bundle the version bump and CI migration in one change.** They edit overlapping
  files (`reef.toml`, Docker args, workflows) and share one acceptance signal (a
  green hosted run on `0.17.1` through the central profiles). Splitting would force
  a throwaway intermediate state (0.17 on local workflows, or 0.14 on wrappers).
  Alternative considered: two sequential changes — rejected as pure churn since
  neither half is independently shippable to `main` without re-verifying the other.

- **Delegate via thin wrappers, not `secrets: inherit` or inline steps.** The
  central contract rejects `secrets: inherit`, inline steps, mutable refs, and
  manifest-pin drift. Each wrapper keeps only `on`, `concurrency`, `permissions`,
  and one `uses:` call passing explicit inputs. Alternative considered: keep local
  workflows and only bump the version — rejected because it leaves the duplicated
  mechanics the migration is meant to delete.

- **Pin the consumer workflow by reviewed full SHA, supplied out-of-band.** The SHA
  is a separate reviewed authority from the compiler pin; it is not inferred from
  the wrapper and must come from the reviewer/rollout record. The `0.14.0`-era SHA
  in the stale worktree is treated as unverified for this change.

- **Commit a `0.17.1` toolchain digest lock and pass the matching digest.** The
  central pin guard reads `.github/chelis-toolchains.json` (`chelis-toolchain-digests/v1`)
  and fails closed unless the wrapper's `chelis-linux-sha256` matches
  `versions["0.17.1"]["linux-x86_64"]`. Both linux-x86_64 and darwin-arm64 digests
  for `0.17.1` are reviewer-supplied inputs, not derivable here.

- **Regenerate sidecars inside the pinned image, then commit.** Recent history shows
  version bumps require regenerating `.dp` sidecars and Octant `spans.json`; the
  Deep drift check and C-backend goldens are hard gates, so regeneration is part of
  this change, not a follow-up.

## Risks / Trade-offs

- **0.17.1 introduces source-breaking changes** → run `chelis check` / `test` in the
  `0.17.1` image early; fix corpus usage before touching CI. If breakage is large,
  the version bump may need its own dependency-pin follow-ups (kept as a noted risk,
  not pre-solved).
- **Reviewed `0.17.1` archive digests are unavailable** → the digest lock and wrapper
  `chelis-linux-sha256` are blocked until the reviewer supplies canonical digests;
  this is an explicit prerequisite, not something to guess.
- **Private-action access from hello-chelis is not configured** → the reusable call
  fails to resolve. Verify `Chelis-Lang/ci` Actions access and that
  `CHELIS_RELEASE_TOKEN` reaches the wrapper before relying on the migration.
- **Required-check context names change** when local jobs become reusable
  caller/job pairs → branch protection must be updated to the new hosted context
  names deliberately, or `main` will appear unprotected/blocked.
- **Two-phase coupling with the central repo**: the accepted `consumer.yml` SHA must
  already be merged and host-validated centrally before these wrappers point at it.

## Migration Plan

1. In the pinned `0.17.1` image, run `chelis check` / `lint --check` / `test tests/`;
   fix any compatibility breakage in the corpus.
2. Bump the pin: `reef.toml`, regenerate `reef.lock`, `docker/Dockerfile` arg,
   `docker/docker-compose.yml` tag.
3. Regenerate sidecars: `python3 scripts/regen_deep.py` (then `--check`), Octant
   `spans.json`, and refresh `verify/expected/*` goldens; commit them.
4. Add `.github/chelis-toolchains.json` with the reviewed `0.17.1` linux + darwin
   digests.
5. Rewrite the four workflows as wrappers selecting the `hello-chelis-*` profiles,
   pinned to the accepted `consumer.yml` SHA, passing `chelis-version: 0.17.1`,
   the matching `chelis-linux-sha256`, dependency pins, and (release)
   `package-version`.
6. Validate each wrapper with `consumer_profiles.py` against this repo's manifest,
   digest lock, and the accepted workflow SHA.
7. Run the hosted CI/lint on a PR; update branch-protection required contexts to the
   new caller/job names; land after green.

**Rollback:** restore the prior four workflow files and the `0.14.0` pin (manifest,
lock, Docker, sidecars) in one revert; never repoint the wrapper at `main` or a
mutable tag, and never alter compiler/Reef pins as part of rollback.

## Open Questions

- What are the reviewed canonical `0.17.1` archive digests for `linux-x86_64` and
  `darwin-arm64`?
- What is the accepted full commit SHA of `consumer.yml` to pin against?
- Does `0.17.1` require bumping any Reef dependency (`coral`, `nautilus`, `school`,
  `octant`, `c-earchin`) for the corpus to build?
