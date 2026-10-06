# Feature matrix

Each capability the corpus demonstrates, the file that demonstrates it, and
the lane that tests it. Unless noted, the test is the file of the same name
under `tests/`, run by `chelis test tests/`.

## Source syntaxes

| Capability | Where | Tested by |
|---|---|---|
| Surf, the human-facing syntax | every `.ch` under `src/`, `tests/`, `tests_neg/`, `verify/` | `chelis check`, `chelis test` |
| Deep, the canonical AST form | [maintained Surf/Deep pairs](surf_and_deep.md) | [`test_surf_deep_equivalence.py`](../tests/test_surf_deep_equivalence.py) |
| LaTeX to Deep | [`octant/`](../octant/), four formulas | [`test_octant_pairs.py`](../tests/test_octant_pairs.py) |
| Deep to Surf | `octant/*.ch`, rendered by `chelis surf` | same |
| EARS requirements to property witnesses | [`c-earchin/finance_options/`](../c-earchin/finance_options/) | [`test_c_earchin_artifacts.py`](../tests/test_c_earchin_artifacts.py) |

## Language

| Feature | Source | Tested by |
|---|---|---|
| Modules; selective and glob imports | [`src/basics/modulesandimports/`](../src/basics/modulesandimports/) | `tests/basics/modulesandimports.ch` |
| ADTs, exhaustive `match`, the `\|>` pipe | [`src/basics/pipeandmatch.ch`](../src/basics/pipeandmatch.ch) | `chelis test` |
| Tensor dimensions in types, no broadcasting | [`src/basics/hellotensor.ch`](../src/basics/hellotensor.ch) | `chelis test` |
| Dimension polymorphism (`[a, b]` binders) | [`src/basics/dimpoly.ch`](../src/basics/dimpoly.ch) | `chelis test` |
| Explicit precision `cast`, no implicit promotion | [`src/basics/precisioncast.ch`](../src/basics/precisioncast.ch) | `chelis test`; compiled in [`verify/cast_lowers.ch`](../verify/cast_lowers.ch) |
| Explicit random keys, replay, and `split_key` | [`src/basics/effectsrandom.ch`](../src/basics/effectsrandom.ch) | `tests/basics/effectsrandom.ch` |
| `IO` effect | [`src/std/tensorio.ch`](../src/std/tensorio.ch) | `chelis test` |
| `Test` effect | every test module | by construction |
| Repeated reads through a `&tensor` parameter | [`src/basics/linearity.ch`](../src/basics/linearity.ch) | `chelis test` |
| `grad` (reverse-mode differentiation) | [`src/basics/gradbasic.ch`](../src/basics/gradbasic.ch), [`src/capstone/blackscholes.ch`](../src/capstone/blackscholes.ch) | `chelis test`; compiled in [`verify/grad_quadratic.ch`](../verify/grad_quadratic.ch), [`verify/grad_works.ch`](../verify/grad_works.ch) |
| `vmap` | [`src/basics/vmap.ch`](../src/basics/vmap.ch) | `chelis test` |
| `realize` | [`src/basics/jitrealize.ch`](../src/basics/jitrealize.ch) | `chelis test`; compiled in [`verify/realize_lowers.ch`](../verify/realize_lowers.ch) |
| Macros | [`src/basics/macrobasic.ch`](../src/basics/macrobasic.ch) | `chelis test` |
| Unbound variable rejected | [`tests_neg/check/unbound_variable.ch`](../tests_neg/check/unbound_variable.ch) | negative suite |
| Dimension mismatch rejected | [`tests_neg/check/dim_mismatch.ch`](../tests_neg/check/dim_mismatch.ch) | negative suite |
| Declared ADT extent checked | [`tests_neg/check/adt_extent_mismatch.ch`](../tests_neg/check/adt_extent_mismatch.ch) | negative suite |
| Missing or reused random key rejected | [`tests_neg/check/keyless_uniform.ch`](../tests_neg/check/keyless_uniform.ch), [`tests_neg/check/reused_random_key.ch`](../tests_neg/check/reused_random_key.ch) | negative suite |
| Precision mismatch rejected | [`tests_neg/check/precision_mismatch.ch`](../tests_neg/check/precision_mismatch.ch) | negative suite |

The negative suite runs twice: `chelis test tests_neg --expect neg` checks
each diagnostic's text, and `pytest tests/test_negative_examples.py` checks
its error kind.

## chelis-std and builtins

| Surface | Source |
|---|---|
| Elementwise math and normalization | [`src/std/elementwise.ch`](../src/std/elementwise.ch) |
| Axis reductions | [`src/std/reductions.ch`](../src/std/reductions.ch) |
| Exact `Std.Decimal` arithmetic | [`src/std/decimal.ch`](../src/std/decimal.ch), [`tests/std/decimal.ch`](../tests/std/decimal.ch) |
| `Std.Datetime` calendar arithmetic | [`src/std/datetimecal.ch`](../src/std/datetimecal.ch), [`tests/std/datetimecal.ch`](../tests/std/datetimecal.ch) |
| `List`, `Dict`, and iteration combinators | [`src/std/collectionsiter.ch`](../src/std/collectionsiter.ch) |
| Text file I/O under `! { IO }` (`Std.Io`) | [`src/std/tensorio.ch`](../src/std/tensorio.ch) |

Tensor `relu` and `sigmoid` are also compiled to C in
[`verify/relu_lowers.ch`](../verify/relu_lowers.ch),
[`verify/sigmoid_lowers.ch`](../verify/sigmoid_lowers.ch), and
[`verify/relu_then_sigmoid.ch`](../verify/relu_then_sigmoid.ch).

## coral

| Surface | Source |
|---|---|
| `from_pairs`, typed columns, `with_column`, `rename`, `drop_column` | [`src/coral/framebasics.ch`](../src/coral/framebasics.ch) |
| `group_by` with `agg_sum` / `agg_mean` | [`src/coral/groupbyagg.ch`](../src/coral/groupbyagg.ch) |
| `inner_join`, `left_join`, `outer_join` | [`src/coral/joins.ch`](../src/coral/joins.ch) |
| `rolling_mean`, `rolling_std`, `ewm` | [`src/coral/windowrolling.ch`](../src/coral/windowrolling.ch) |
| `pivot`, `melt` | [`src/coral/reshape.ch`](../src/coral/reshape.ch) |
| CSV round trip | [`src/coral/io.ch`](../src/coral/io.ch) |
| A frame built from a tensor, and `grad` of a tensor loss | [`src/coral/adthroughdataframe.ch`](../src/coral/adthroughdataframe.ch) |

## nautilus

| Surface | Source |
|---|---|
| `Nautilus.Special`: `erf`, `erfc`, `erfinv`, `log_gamma`, `bessel_j0` | [`src/nautilus/specialfunctions.ch`](../src/nautilus/specialfunctions.ch) |
| `Nautilus.Distributions`: normal pdf / cdf / quantile, exponential cdf | [`src/nautilus/distributions.ch`](../src/nautilus/distributions.ch) |
| `Nautilus.LinAlg`: `matvec`, inner product, L2 norm, `solve_2x2` | [`src/nautilus/linalg.ch`](../src/nautilus/linalg.ch) |
| `Nautilus.Stats`: mean, variance, std, median, quantile, correlation | [`src/nautilus/stats.ch`](../src/nautilus/stats.ch) |
| `Nautilus.Info`: Shannon entropy and KL divergence | [`src/nautilus/info.ch`](../src/nautilus/info.ch) |
| `Nautilus.Distance`: Euclidean, Manhattan, Chebyshev, cosine | [`src/nautilus/distance.ch`](../src/nautilus/distance.ch) |
| `Nautilus.Roots`: bisection, Newton, Brent | [`src/nautilus/roots.ch`](../src/nautilus/roots.ch) |
| `Nautilus.Integrate`: trapezoid, Simpson, 5-point Gauss-Legendre | [`src/nautilus/integration.ch`](../src/nautilus/integration.ch) |
| `Nautilus.Ode`: Euler, RK4 | [`src/nautilus/odenutilus.ch`](../src/nautilus/odenutilus.ch) |
| `Nautilus.Sde`: Euler-Maruyama | [`src/nautilus/sde.ch`](../src/nautilus/sde.ch) |
| `Nautilus.Interpolation`: linear, cubic Hermite | [`src/nautilus/interpolation.ch`](../src/nautilus/interpolation.ch) |
| `Nautilus.Optim`: golden section, Brent, Newton | [`src/nautilus/optimize.ch`](../src/nautilus/optimize.ch) |
| `Nautilus.Testing`: z and one-sample t statistics, p-values | [`src/nautilus/hypothesis.ch`](../src/nautilus/hypothesis.ch) |
| `Nautilus.CurveFit`: one-parameter Levenberg-Marquardt | [`src/nautilus/curvefit.ch`](../src/nautilus/curvefit.ch) |

## octant

| LaTeX | Files |
|---|---|
| `d = e^{-r t}` | [`octant/discount_factor.*`](../octant/) |
| `a = p (1 + r/n)^{n t}` | [`octant/compound_interest.*`](../octant/) |
| `d_1 = (\ln(s/k) + (r + \sigma^2/2) t) / (\sigma \sqrt{t})` | [`octant/black_scholes_d1.*`](../octant/) |
| `y = \phi(x)` | [`octant/normal_pdf.*`](../octant/) |

## Capstones

| Capstone | Uses | Source | Tested by |
|---|---|---|---|
| Black-Scholes call price, delta, vega | nautilus | [`blackscholes.ch`](../src/capstone/blackscholes.ch) | `chelis test`; compiled Greek calls in `test_c_backend.py` |
| Linear regression with an SGD step | chelis-std | [`linreg.ch`](../src/capstone/linreg.ch) | `chelis check` only |
| Returns and risk pipeline | coral, nautilus | [`returnsrisk.ch`](../src/capstone/returnsrisk.ch) | `chelis test` |

## Not covered here

- Local `@property` declarations proven with `chelis prove`. The c-earchin
  fixtures exercise `chelis prove` on generated witnesses instead.
- `jit`. The `jitrealize.ch` example shows `realize` next to an eager
  baseline but does not use `jit` itself.
- GPU backends. CI has no GPU, so the C backend is the only compiled target.
- Differentiating through dataframe operations, which is blocked by
  [chelis#2552](https://github.com/Chelis-Lang/chelis/issues/2552).
