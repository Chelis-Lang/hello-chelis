# Chelis Capability Surface (this shell)

<!-- BEGIN CHELIS MANAGED BLOCK: chelis-surface-header chelis@0.16.1 (sha256:28011bed9ccb5778) -->
This file is a domain-scoped view of the canonical Chelis capability surface,
generated for the pinned toolchain. Each capability row is marked `@pin` (usable
at the current pin) or `@upstream` (lands at the next bump). **Read it before
designing around a suspected language gap** — most downstream over-narrowing
traces to not knowing the real surface. Regenerate with `chelis reef conform
sync` at every pin bump; the upstream source of truth is `docs/CHELIS_SURFACE.md`
in `Chelis-Lang/chelis`.
<!-- END CHELIS MANAGED BLOCK: chelis-surface-header -->

## Capabilities

| Capability | Status | Executable evidence |
|---|---|---|
| Exact compiler/dependency closure: Chelis 0.16.1, Std 0.4.0, Coral 0.7.31, Nautilus 0.7.34, School 0.1.10 | `@pin` | `reef.toml`, `reef.lock`, `scripts/check_workflow_pins.py` |
| Direct tensor and scalar `grad` | `@pin` | `tests/basics/gradbasic.ch`; C goldens under `verify/` |
| Black-Scholes grad through Nautilus `normal_cdf` | `@upstream` | `tests_blocked/capstone/blackscholes_grad.ch`; parked issue draft |
| `realize` in evaluator and C backend | `@pin` | `tests/basics/jitrealize.ch`; `verify/realize_lowers.ch` |
| Rank-1 to rank-2 `vmap` | `@pin` | `tests/basics/vmap.ch` |
| Tensor activation pipelines (`relu` → `sigmoid`) in evaluator and C | `@pin` | `tests/basics/pipeandmatch.ch`; activation C goldens |
| Seeded random execution in evaluator and C | `@pin` | `tests/basics/effectsrandom.ch`; 0.16.1 package-context reprobe |
| `expand` shape agreement and nested numeric `to_tensor` literals | `@pin` | `tests/capstone/linreg.ch`; reprobe evidence |
| f32/f64 tensor casts | `@pin` | `tests/basics/precisioncast.ch`; `verify/cast_lowers.ch` |
| bf16/f16 C host-boundary rendering and conversion | `@upstream` (`chelis#716`) | manual C reprobe in `tests_blocked/README.md` |
| Coral CSV/JSON frame I/O | `@pin` | `tests/coral/io.ch` |
| Coral Parquet frame I/O | `@upstream` | `tests_blocked/coral/parquet.ch`; Coral v0.7.31 source stub |
| Octant LaTeX → Deep/spans → Surf round trip | `@pin` | `tests/test_octant_pairs.py` with standalone Octant 0.10.1 |
| c-earchin proof artifacts through `chelis prove` | `@pin` | `tests/test_c_earchin_artifacts.py` |
