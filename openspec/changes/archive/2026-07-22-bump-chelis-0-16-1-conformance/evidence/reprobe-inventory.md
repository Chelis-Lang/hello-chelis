# Chelis 0.16.1 reprobe inventory

All probes run in the authenticated `hello-chelis:0.16.1` release image. A scratch probe is copied outside the Reef root when the claim is not represented by an executable fixture; surviving expressible blockers graduate to `tests_blocked/` only after their diagnostic is observed.

No tracked source or learner document currently cites a `chelis#NNN` issue for these claims. `docs/discrepancies.md` carries uncited diagnostic prose, so every surviving limitation needs an upstream source before it can remain current documentation.

## Version-sensitive behavior

| ID | Current claim / narrowing | Current sites | `check` probe | `eval` / `test` probe | Reef build probe | C-backend probe |
|---|---|---|---|---|---|---|
| R1 | `grad` is unavailable in the host runtime | `docs/discrepancies.md`; `src/{basics,capstone,coral}/README.md`; `src/basics/gradbasic.ch`; `src/capstone/{blackscholes,linreg}.ch`; `src/coral/adthroughdataframe.ch` | check each source | targeted scratch calls plus native suites | `chelis reef build` | `tests/test_c_backend.py -k grad` |
| R2 | C lowering rejects direct `grad(f)(x)` but accepts the wrapper-function-parameter form | `docs/discrepancies.md`; `verify/{grad_works,grad_quadratic}.ch` | direct and wrapper scratch modules | evaluate/test both forms | root Reef build for direct corpus form | build both scratch forms and run wrapper goldens |
| R3 | The C-wrapper form causes a project-wide lowered-root-count mismatch in `chelis test` | `docs/discrepancies.md`; split between `src/basics/gradbasic.ch` and `verify/grad_works.ch` | check the wrapper variant | temporary source substitution followed by `chelis test tests/` | `chelis reef build` | wrapper golden |
| R4 | `realize` is unavailable in the host runtime | `docs/discrepancies.md`; `src/basics/jitrealize.ch`; `tests/basics/jitrealize.ch`; `verify/realize_lowers.ch` | check source | targeted scratch invocation and native test | `chelis reef build` | `tests/test_c_backend.py -k realize` |
| R5 | `vmap` has the same C-lowering restriction as `grad` | `docs/discrepancies.md`; `src/basics/vmap.ch`; `tests/basics/vmap.ch` | check source | targeted `batch_process` invocation | `chelis reef build` | direct and wrapper scratch builds |
| R6 | Tensor `relu`/`sigmoid` and related activations are unavailable in the host runtime | README caveat; `docs/discrepancies.md`; `src/basics/pipeandmatch.ch`; `src/std/activationsnorms.ch`; smoke-only tests | check sources | targeted `activate`/`pipeline` calls plus native tests | `chelis reef build` | activation goldens in `tests/test_c_backend.py` |
| R7 | Piped activation chains lose their tensor result in C while direct nesting works | `docs/discrepancies.md`; `src/basics/pipeandmatch.ch`; direct-call `verify/relu_then_sigmoid.ch` | check pipe and direct forms | evaluate both | `chelis reef build` | build/run both scratch forms and compare |
| R8 | `with seed(...)` blocks every project C build and only evaluates in the host lane | `docs/discrepancies.md`; `verify/README.md`; `tests/test_c_backend.py`; `src/basics/effectsrandom.ch` | check source | targeted seeded evaluation/native test | `chelis reef build` | isolated source build and whole-project build |
| R9 | `expand` types `[64,1]` but evaluates `[64]`, preventing LinReg runtime use | `docs/discrepancies.md`; `src/capstone/linreg.ch` | check source | targeted `predict` shape/value probe | `chelis reef build` | isolated fixed-input LinReg build/run |
| R10 | Nested two-dimensional `to_tensor` literals are rejected; `pad_sequences` is required | `docs/discrepancies.md` | scratch nested-literal check | scratch evaluation/test if accepted | scratch Reef build | build/run if accepted |
| R11 | Tensor `bf16` cast is rejected, while f32/f64 round trips work | `docs/discrepancies.md`; `src/basics/precisioncast.ch`; `verify/cast_lowers.ch` | scratch bf16 check plus source check | native precision tests | `chelis reef build` | cast golden plus bf16 build if accepted |
| R12 | Higher-order scalar (`f32 -> f32`) wrappers are omitted by C codegen | `docs/discrepancies.md`; tensor wrapper forms in `verify/` | scalar and tensor wrapper checks | evaluate both | scratch Reef build | build/link/run scalar and tensor wrappers |
| R13 | `copy(scalar)` is invalid | `docs/discrepancies.md` | scratch check | not applicable unless accepted | scratch Reef build | not a blocker if still rejected by the language contract |
| R14 | `chelis check` accepts only one file, not a directory | `docs/discrepancies.md`; README command guidance | `chelis check src/basics/` and a single-file control | not applicable | `chelis reef build` control | not applicable |
| R15 | Coral Parquet imports check but fail because the runtime symbol is absent | `docs/shells/coral.md` | scratch `Std.Io.Parquet` import | targeted runtime call if an API fixture can be formed | scratch Reef build | link/run if build succeeds |

## Generated and bridge artifacts

| Surface | Authority | Drift / execution probe |
|---|---|---|
| Surf → Deep sidecars under `src/`, `tests/`, `verify/` | sibling `.ch` source | `python3 scripts/regen_deep.py --check` |
| Octant Deep, spans, and decompiled Surf | `octant/*.tex` | `python3 -m pytest -q tests/test_octant_pairs.py`; regenerate only with `scripts/regen_octant.py` |
| c-earchin proof fixtures | committed released bridge output under `c-earchin/finance_options/` | `python3 -m pytest -q tests/test_c_earchin_artifacts.py` |
| C expected outputs | executable `verify/*.ch` | `python3 -m pytest -q tests/test_c_backend.py`; update only from reviewed runtime output |

## Historical/version-only claims to reconcile after probes

- README, getting-started, testing, architecture, feature matrix, shell docs, and source READMEs still name Chelis `0.8.0` and older dependency releases.
- `docs/testing_cutover_0.7.6.json`, `CHANGELOG.md`, and `docs/upstream_resolved/` are historical records; their old versions remain only when explicitly labeled historical.
- Octant `0.10.1` remains the standalone translator binary; its source-only Reef package is intentionally not installed because that published package pins Chelis `0.14.0`.
- c-earchin proof artifacts are committed and executed directly through Chelis; its `0.3.3` Reef package is intentionally not installed because the released package pins Chelis `0.14.0`.
