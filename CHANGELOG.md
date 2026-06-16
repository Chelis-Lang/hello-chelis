# Changelog

All notable changes to hello-chelis are documented here. The format
follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); this
corpus tracks the Chelis toolchain, so each entry pairs a hello-chelis
version with the compiler and shell releases it is pinned to.

## [Unreleased]

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
