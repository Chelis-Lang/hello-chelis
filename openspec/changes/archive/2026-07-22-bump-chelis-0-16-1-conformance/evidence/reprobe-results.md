# Chelis 0.16.1 per-verb reprobe results

## Completion contract

Goal: classify every row in `reprobe-inventory.md` from observed `0.16.1` behavior before editing the corpus. A successful `check` alone is not completion evidence; runtime claims require eval/test output, and C claims require generated C to compile and execute. False-completion cases excluded here include build-only success, unexecuted C, a scratch probe that cannot resolve the package graph, and a probe failure caused by an unrelated C identifier collision.

Authority and budget: the authenticated `hello-chelis:0.16.1` image, 15 inventory rows, front-end/evaluator/C lanes, one focused pass plus one adversarial pass. The adversarial pass caught the bf16 print-boundary corruption and rejected an initial tensor-wrapper failure caused only by naming a function `double` (a C keyword); the corrected `twice` control passed.

## Results

| ID | Verdict | Observed evidence at `0.16.1` |
|---|---|---|
| R1 `grad` host runtime | **partially fixed** | Direct tensor grad evaluated to `[2,4,6]`; direct scalar grad evaluated to `6`, and both C programs matched. The real Black-Scholes `delta`/`vega` call graph still fails native execution with `if condition must be bool, got Tensor(...)`; the exact-value delta case is retained under `tests_blocked/capstone/`. |
| R2 direct-vs-wrapper C grad | **fixed for the carried contract** | Direct and wrapper forms both checked, generated C, compiled, and ran with `[2,4,6]`; the direct form no longer needs a C-only workaround. |
| R3 wrapper evaluator root mismatch | **still reproduces, workaround retired** | The wrapper scratch probe still fails eval with `lowered root count mismatch: expected 2 named roots, got 1`, while the direct form passes every lane. The wrapper existed only to dodge the old C restriction, so the corpus will remove that workaround rather than carry a new narrowing. |
| R4 `realize` host runtime | **fixed** | Eval produced `[1,4,9]`; generated C compiled and ran with `[1,4,9]`. |
| R5 `vmap` restriction | **fixed** | Eval and C both produced a `[2,3]` tensor with doubled rows. |
| R6 activation host runtime | **fixed** | Piped and direct `relu`→`sigmoid` both evaluated to `[0.5,0.5,0.7310586]`; both C binaries matched. |
| R7 pipe activation C shape loss | **fixed** | The piped and direct C binaries emitted the same rank-1 tensor and values; no unit-valued result remains. |
| R8 project-wide `with seed` C rejection | **fixed** | The package-context seed probe checked and evaluated deterministically; whole-package C generation, compilation, and execution succeeded with a rank-1 random tensor. |
| R9 `expand` shape divergence | **fixed** | `check` scored 1.0 and eval/C both produced shape `[2,1]`, not the old runtime shape `[2]`. |
| R10 nested `to_tensor` | **fixed** | Nested numeric lists checked, evaluated, and ran in C as a `[2,2]` tensor with values `[1,2,3,4]`. |
| R11 bf16 cast | **partially fixed / still blocked on C output** | Check and eval accept tensor f32→bf16 and eval displays `[1,2]`; generated C compiles, but execution prints `[2.003875732421875,0.0]`. This is the open `chelis#716` host-boundary buffer misread. Keep f32/f64 learner code and document the C boundary. |
| R12 higher-order scalar/tensor wrappers | **fixed** | Scalar and corrected tensor wrappers checked/evaluated/generated C/compiled/ran, producing `4` and `[2,4,6]`. |
| R13 `copy(scalar)` | **working as designed, not a limitation** | All lanes reject it with `copy requires tensor input, got f32`; the diagnostic also identifies `copy()` as redundant migration compatibility. Remove it from the workaround inventory. |
| R14 directory `check` | **drifted / not a supported completion oracle** | `chelis check src/basics/` no longer returns the old immediate argument error, but did not complete after 30 minutes in the image and was stopped. `check --help` still specifies `<FILE>`. Keep per-file checking as command-contract guidance, not as a current compiler bug claim. |
| R15 Coral Parquet | **still unavailable** | In package context, `read_parquet_frame` checks and generates compilable C, but eval and the C binary fail with `read_parquet_frame requires Std.Io.Parquet (not in current runtime)`. Coral `v0.7.31:src/io.ch` explicitly implements this API as `fail(...)`; describe it as an unavailable Coral capability rather than an uncited Chelis regression. |

## Generated/bridge observations

The scratch probes did not alter committed generated artifacts. Authoritative Deep, Octant, c-earchin, and C-golden drift checks remain mandatory after de-narrowing source edits. Octant stays on the standalone `0.10.1` translator binary; source-only Octant and c-earchin Reef packages are not installed because their published manifests pin Chelis `0.14.0` and neither is needed to execute this repository's committed bridge evidence.

## Approach-family registry

| Family | Mechanism / artifact | State |
|---|---|---|
| host-evaluator | formatted standalone and package-context eval probes with concrete root values | validated for each fixed claim; wrapper/Parquet failures retained above |
| generated-C | `chelis build`, GCC link, and binary execution for every successful scratch build | validated; exposed `chelis#716` despite check/eval success |
| package-context | temporary modules under the declared `src/` root for Std/Coral imports, then whole-package generation | validated; removed scratch modules after execution |
| command-contract | directory argument trial plus `check --help` authority | drifted; deliberately not generalized into directory support |

Terminal result: **validated classification**. Residual uncertainty is limited to performance/termination semantics of directory `check`, which is not used as an acceptance oracle.
