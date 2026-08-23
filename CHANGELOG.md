# Changelog

All notable changes to hello-chelis are documented here. The format
follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); this
corpus tracks the Chelis toolchain, so each entry pairs a hello-chelis
version with the compiler and shell releases it is pinned to.

## [Unreleased]

Two cascades land in this window. 0.1.11 was never tagged, so both are
described here as one net change from 0.1.10.

#### Pin bumps (net, 0.1.10 -> this window)

- compiler `=0.14.0` -> `=0.17.1` -> `=0.18.5`
- `coral` `0.7.30` -> `0.7.32` -> `0.7.39`
- `nautilus` `0.7.33` -> `0.7.35` -> `0.7.42`
- `school` `0.1.9` -> `0.1.12` -> `0.1.13`
- `chelis-std` stays `0.4.0`

`coral` 0.7.39, `nautilus` 0.7.42, and `school` 0.1.13 are the versions
**staged** in those shells' own bump PRs (coral#27, nautilus#43, school#190),
not yet tagged. Pinning the staged numbers keeps this PR merge-ready as written
once the cascade tags.

The manifest, Docker `ARG` defaults, CI build-args, release workflow env,
Compose image tag, README, and version-scoped discrepancy docs move together.
`reef.lock` still records the last versions with real published artifacts
(`coral` 0.7.38, `nautilus` 0.7.41, `school` 0.1.12). It cannot record the staged
numbers honestly until those tags exist, because the lock stores artifact hashes
and a locally built package's bytes are not the release's. Regenerate the whole
file with `chelis reef build` as the last step of the cascade.

### Chelis 0.18.5 cascade

The corpus was migrated to **canonical Surf v0.19** (chelis#1031, shipped in
0.18.4), which the style gate now enforces ahead of `build`, `check`,
`validate`, and `eval --file`. 33 of 93 `.ch` files failed `chelis fmt --check`
on the new grammar. `chelis migrate surf --from 0.18 --inplace` rewrote 28 of
them across three classes: a one-expression block (`= { expr }` -> `= expr`),
redundant zero-axis decoration (`vmap(f, axis=0)` -> `vmap(f)`), and
non-canonical float literals (`0.000001` -> `1e-6`). The five `src/coral/`
files were hand-migrated; see the blocker note below.

Three source changes are semantic rather than syntactic:

- `expand` now requires an `int64` size. `src/capstone/linreg.ch` and
  `tests/coral/adthroughdataframe.ch` grew explicit `i64` suffixes
  (`expand(b, 0, 64)` -> `expand(b, 0, 64i64)`).
- Every `.dp` sidecar was regenerated. Deep now carries `surf_path` module
  metadata, and span offsets moved with the source rewrites.
- The `octant/*.ch` third of each LaTeX triple was regenerated: 0.18.5's
  resugarer prints infix operators (`(a + b) / c`) where 0.17.1 printed prefix
  builtin calls (`div(add(a, b), c)`). The `.tex` and `.dp` halves are
  unchanged, because the octant pin did not move.

Two `verify/expected/*.txt` goldens changed **rendering only**, not value: the
runtime now prints an f32 at its own dtype width
(`0.11920292`, not the double-rendered `0.1192029193043709`). Confirmed as a
toolchain change by rebuilding the same program with 0.17.1 on the same
machine. `tests/test_c_backend.py` compares numerically, so either spelling
passes it; the files were updated to match a fresh capture.

#### Conformance retrofit

This repo had never been through `chelis reef conform`. The audit reported 8
MUST failures; it now reports none. Added `AGENTS.md` (+ `CLAUDE.md` symlink)
with the stamped pointer managed block, `docs/CHELIS_SURFACE.md`,
`docs/UPSTREAM_BUGS.md`, `docs/issue_drafts/`, `tests_blocked/README.md`, and
the vendored `agent-skills/` set. The compile-rejection corpus moved from
`tests/negative/` to `tests_neg/check/` with `.expect` sidecars and now runs
under two oracles: `chelis test tests_neg --expect neg` (diagnostic substring)
and `tests/test_negative_examples.py` (structured error kind). CI gained the
offline pin guard (`chelis reef conform bump-check`) and the negative suite.

#### Known blockers

- **The cascade is untagged.** All three sibling shells have their 0.18.5 bump
  staged but not released, so the Docker image cannot fetch them and CI stays
  red until they tag. Nothing else is outstanding: the corpus is validated
  against all three staged sources locally.
- **chelis#1258** — `Frame[N]` desugars to `(t-var {} N)`, so `chelis surf` and
  `chelis migrate surf` fail on the five `src/coral/` files. Filed upstream
  during this bump with a self-contained reproducer.

#### Validation

Validated against the real staged sources rather than a waiver. `coral` 0.7.39,
`nautilus` 0.7.42, and `school` 0.1.13 were built from their bump-PR branch heads
(d90ee05, c060cb92, 26bab5b) into a private Reef registry, and the corpus runs
against them with **no dependency-compiler drift waiver and nothing parked**:
`chelis reef build`, `chelis lint --check .` (zero error-severity findings; the
one pre-existing `prefer-pipe-operator` advisory in
`src/capstone/transformerblock.ch` remains), `chelis fmt --check` over all 93
`.ch` files, `chelis test tests/ --jobs auto` (**105 passed / 0 failed**),
`chelis test tests_neg --expect neg` (3/3), `python3 scripts/regen_deep.py
--check`, and `python3 -m pytest tests/` (97 passed, 4 skipped for the absent
octant binary, 7 C-backend cases failing only because macOS `clang` has no
`-fopenmp`). Those
7 were re-run by hand against Accelerate: 5 byte-exact goldens and the 2
rendering-only diffs described above. The Docker image build, the valgrind
lane, and the octant round-trip validate in CI.

### 0.1.10 - 2026-06-19

Cascaded the corpus from chelis 0.7.27 to chelis 0.8.0.

#### Pin bumps

- compiler `=0.7.27` -> `=0.8.0`
- `coral` `0.7.25` -> `0.7.26`
- `nautilus` `0.7.26` -> `0.7.27`
- `octant` `0.4.8` -> `0.4.9`
- `c-earchin` `0.3.1` -> `0.3.2`
- `school` `0.1.4` -> `0.1.5`
- `chelis-std` stays `0.4.0` (compiler-bundled)

Bumped across `reef.toml`, `reef.lock` (regenerated against the new
releases via `chelis reef build`), the Docker image
(`docker/Dockerfile` ARGs, `docker/docker-compose.yml` image tag),
`.github/workflows/release.yml` env, `README.md`, and the current
`docs/` and per-area `README.md` references.

#### Validation

Validated with chelis 0.8.0 and the released shell packages:
`chelis reef build`, `chelis check src/basics/hellotensor.ch`,
`chelis lint --check .`, `python3 scripts/regen_deep.py --check`,
`chelis test tests/ --jobs auto`, `python3 -m pytest -q tests/`,
`python3 -m ruff check tests/`, `python3 -m black --check tests/`,
and the Docker image build/smoke for `hello-chelis:0.8.0`. Strict
lint exits zero with the existing non-blocking `prefer-pipe-operator`
advisory in `src/capstone/transformerblock.ch`.

### 0.1.9 - 2026-06-19

Cascaded the corpus from chelis 0.7.26 to chelis 0.7.27. This is a
clean pin bump: no source migration was required and no 0.7.27
breaking change fired on this corpus.

#### Pin bumps

- compiler `=0.7.26` -> `=0.7.27`
- `coral` `0.7.24` -> `0.7.25`
- `nautilus` `0.7.25` -> `0.7.26`
- `octant` `0.4.7` -> `0.4.8`
- `c-earchin` `0.3.0` -> `0.3.1`
- `school` `0.1.3` -> `0.1.4`
- `chelis-std` stays `0.4.0` (compiler-bundled)

Bumped across `reef.toml`, `reef.lock` (regenerated against the new
releases via `chelis reef build`), the Docker image
(`docker/Dockerfile` ARGs, `docker/docker-compose.yml` image tag),
`.github/workflows/release.yml` env, `README.md`, and the `docs/` and
per-area `README.md` references.

#### ML relocation re-verified

The 0.1.8 cascade moved the corpus's neural-network and loss imports
out of `chelis-std` and into the `school` package (`School.Nn.*`,
`School.Loss.*`). Those imports now resolve from `school@v0.1.4`; no
`Std.Nn.*` / `Std.Loss.*` imports remain and no re-migration was
needed. `chelis reef build` resolves the full dependency closure
cleanly.

#### Validation

`chelis reef build` is clean against chelis 0.7.27; the lockfile pins
were regenerated for the new shell releases. Front-end check, native
`chelis test`, Deep-drift, C-backend, Octant, c-earchin, and negative
harnesses run in the Docker-based PR CI against the freshly bundled
toolchain.

### 0.1.8 - 2026-06-16

Migrated the corpus from chelis 0.7.20 to chelis 0.7.26 (chelis-std
0.4.0).

#### chelis-std ML modules moved to the `school` package

`chelis-std` 0.4.0 removed the neural-network and loss modules and they
now live in the new `school` package (`school@v0.1.3`). The imports were
remapped one-for-one (`Std.*` -> `School.*`):

- `Std.Nn.Silu` -> `School.Nn.Silu` (`sigmoid_scalar`)
- `Std.Nn.Gelu` -> `School.Nn.Gelu` (`gelu_scalar`, `tanh_scalar`)
- `Std.Nn.RmsNorm` -> `School.Nn.RmsNorm` (`rms_scale`)
- `Std.Loss.CrossEntropy` -> `School.Loss.CrossEntropy` (`loss`)
- `Std.Loss.Bce` -> `School.Loss.Bce` (`bce_with_logits`)
- `Std.Loss.KlDiv` -> `School.Loss.KlDiv` (`kl_divergence`)
- `Std.Loss.Metrics` -> `School.Loss.Metrics` (`perplexity`)

Affected files: `src/std/activationsnorms.ch`,
`src/std/reductionslosses.ch`, `tests/std/activationsnorms.ch`.
`Std.Tensor.Reduce` (`prod`) and the non-ML std modules (`Std.Time`,
`Std.Decimal`, `Std.Io`, `Std.Init.Random`, `Std.Test`) remain in
`chelis-std`.

School's loss signatures changed ownership versus the old std ones:
`School.Loss.CrossEntropy.loss` and `School.Loss.KlDiv.kl_divergence`
take owned tensors (the std versions took `&`-borrows), while
`School.Loss.Bce.bce_with_logits` keeps the borrowed form. The
`ce_loss` and `kl_loss` wrappers in `src/std/reductionslosses.ch` were
updated to owned parameters to match.

#### Pin bumps

- compiler `=0.7.20` -> `=0.7.26`
- `chelis-std` `0.3.0` -> `0.4.0`
- `coral` `0.7.18` -> `0.7.24`
- `nautilus` `0.7.19` -> `0.7.25`
- `octant` `0.4.6` -> `0.4.7`
- `c-earchin` `0.2.5` -> `0.3.0`
- added `school` `0.1.3` to `[dependencies]`

Bumped across `reef.toml`, `reef.lock`, the Docker image
(`docker/Dockerfile` ARGs + a new `SCHOOL_VERSION` install step,
`docker/docker-compose.yml` image tag), `.github/workflows/release.yml`
env, `README.md`, and the `docs/` and per-area `README.md` references.

#### Breaking-change migrations applied

- **chelis#317 / mechanism #157 (explicit cross-module constructor
  imports):** `chelis reef build` reported `UnboundVariable` /
  `UnknownConstructor` for the Coral `Column` constructors `FloatCol`
  and `StringCol`. They are now named explicitly in each importing
  module's `Coral.Frame (...)` import:
  `src/coral/framebasics.ch`, `src/coral/adthroughdataframe.ch`,
  `src/coral/groupbyagg.ch`, `src/coral/io.ch`, `src/coral/joins.ch`,
  `src/coral/reshape.ch`, and `src/capstone/mlpipeline.ch`.
- **Coral `Frame` row-dimension parameter:** `Hello.Capstone.MlPipeline.build_frame`
  declared a bare `-> Frame`; `from_pairs` now produces the
  dimension-parameterized `Frame[n]`, so the return type was made
  honest as `-> Frame[n]`.
- **prove summary additivity (chelis 0.7.26):** the `chelis prove
  --json` summary grew an additive `obligations` field. The
  c-earchin pass-case assertion in
  `tests/test_c_earchin_artifacts.py` was relaxed from exact-dict
  equality to per-field checks that tolerate the additive key.

chelis#370 (return-position dim rigidity) and chelis#397 (rank
monomorphization) did not fire on this corpus.

#### Validation

`chelis reef build` is clean; `chelis check` reports zero errors;
`chelis lint --check .` passes (one pre-existing advisory
`prefer-pipe-operator` warning on `src/capstone/transformerblock.ch`,
non-blocking); `chelis test tests/` reports 105 passed / 0 failed; the
Python harness reports 105 passed (89 Deep-drift + 7 C-backend + 4
Octant + 3 negative + 2 c-earchin) after regenerating every `.dp`
sidecar for the 0.7.26 `chelis deep` output. The c-earchin prove
pass/fail cases were re-verified under 0.7.26 (6/6 passed; the failure
fixture still resolves `req_FIN_003` back to its EARS line).
