# Feature matrix

What from the primer is exercised, where, and which corner cases each
example pins down.

## Language

| Primer claim | Example file | Notes |
|---|---|---|
| Surf and Deep round-trip | covered by `scripts/run_examples.py` (calls `chelis surf` + `chelis deep` on every file) | round-trip equality up to formatting |
| Module + import (3 forms) | `01_language_basics/03_modules_and_imports/` | qualified, selective, glob |
| ADTs + exhaustive match | `01_language_basics/02_pipe_and_match.ch` | missing-arm error reproduced in `tests/expected/` |
| Named dimensions, no broadcasting | `01_language_basics/01_hello_tensor.ch`, `04_dimension_polymorphism.ch` | mismatch is a compile error |
| No implicit precision promotion | `01_language_basics/05_precision_and_cast.ch` | `add(f32, bf16)` rejected; explicit `cast` required |
| Effects: `Random` + handler | `01_language_basics/06_effects_random.ch` | `with seed(...)` discharges the effect |
| Effects: `IO` | `02_std/tensor_io.ch` | `Std.Io.write_tensor` carries `! { IO }` |
| Linearity: consume / `copy` / `&borrow` | `01_language_basics/07_linearity_copy_borrow.ch` | use-after-consume rejected |
| `grad` (reverse-mode AD) | `01_language_basics/08_grad_basic.ch`, all capstones | finite-diff cross-check in tests |
| `vmap` | `01_language_basics/09_vmap.ch` | per-example fn lifted to batched fn |
| `jit`, `realize`, `cast`, `copy` | `01_language_basics/10_jit_and_realize.ch` | each as a dedicated transform |
| Macros | `01_language_basics/11_macro_basic.ch` | macro expanding to typed Deep |

## chelis-std

| Surface | Example file |
|---|---|
| activations + normalizations | `02_std/activations_norms.ch` |
| reductions + losses (mse, mean, var) | `02_std/reductions_losses.ch` |
| `Decimal[P, S]` | `02_std/decimal_arithmetic.ch` |
| `DateTime`, `Duration`, `BusinessDay` | `02_std/datetime_calendar.ch` |
| `List`, `Dict`, fold/scan/map/filter/partition | `02_std/collections_iteration.ch` |
| Tensor I/O (CSV, JSON, safetensors) | `02_std/tensor_io.ch` |

## coral

| Surface | Example file |
|---|---|
| typed columns, `from_pairs`, `with_column` | `03_coral/frame_basics.ch` |
| `group_by` + aggregations | `03_coral/groupby_agg.ch` |
| `inner_join`, `left_join`, `outer_join` | `03_coral/joins.ch` |
| rolling windows + EWM | `03_coral/window_rolling.ch` |
| `pivot`, `melt`, `stack`, `unstack` | `03_coral/reshape_pivot.ch` |
| CSV + JSON I/O | `03_coral/csv_json_io.ch` |
| **AD through a dataframe pipeline** | `03_coral/ad_through_dataframe.ch` |

## nautilus

| Surface | Example file |
|---|---|
| `erf`, `gamma`, `Bessel`, `Airy` | `04_nautilus/special_functions.ch` |
| `Normal`, `Poisson`, `Beta` (pdf/cdf/inv) | `04_nautilus/distributions.ch` |
| `solve`, `Cholesky`, `CG`, `eig` | `04_nautilus/linalg.ch` |
| moments / quantile / correlation | `04_nautilus/statistics.ch` |
| Euclidean / Mahalanobis / cosine | `04_nautilus/distance_metrics.ch` |
| bisection / Newton / Brent | `04_nautilus/roots_brent.ch` |
| trapezoid / Simpson / Gauss-Hermite | `04_nautilus/integration.ch` |
| Euler / RK4 / RK45 ODE | `04_nautilus/ode_rk45.ch` |
| Euler-Maruyama / Milstein SDE | `04_nautilus/sde_milstein.ch` |
| linear / cubic Hermite interpolation | `04_nautilus/interpolation.ch` |
| golden-section + Brent minimize | `04_nautilus/optimization_1d.ch` |
| z-test / t-test / chi-squared | `04_nautilus/hypothesis_tests.ch` |
| single-param Levenberg-Marquardt | `04_nautilus/curve_fit_lm.ch` |

## octant

| Translation | Example pair |
|---|---|
| basic LaTeX (`∫`, `∇`, `∂`, `∑`) | `05_octant/basic_latex.tex` ↔ `basic_latex.ch` |
| named distributions (`N(d_1)`, `Φ`, `φ`) | `05_octant/distributions_latex.tex` ↔ `.ch` |
| AD through an Octant-translated formula | `05_octant/ad_through_latex.{tex,ch}` |

The `.tex` is the input. The `.ch` is the verified output of `octant
translate`. The harness asserts the pair stays in lockstep — running
`octant translate <tex>` regenerates the `.ch` and the diff must be empty.

## Capstones

| Capstone | Shells used | Highlight |
|---|---|---|
| `06_capstone/black_scholes_greeks/` | octant + nautilus + std | `grad` over an Octant-translated Black-Scholes formula yields Greeks; cross-checked against finite differences |
| `06_capstone/linear_regression/` | coral + std + nautilus | Coral frame → MSE loss → `grad` → Nautilus `solve` cross-check |
| `06_capstone/transformer_block/` | std (only) | the primer's transformer-block walkthrough as a runnable example |
| `06_capstone/ml_pipeline/` | all four | CSV via Coral → feature engineering → `grad`-trained model → Nautilus statistical evaluation. The "everything bagel". |

## Trust stack (L1 only — L2 properties are designed but not yet shipped)

| Layer | Where it shows up |
|---|---|
| L1 type/dim/effect/linearity | every example (anything that compiles is L1-clean) |
| Audit chain (span survival) | `tests/test_chelis_build.py` greps `// span:` from emitted C |
| `chelis lint --check` | `tests/test_lint.py` enforces nomenclature on every commit |
