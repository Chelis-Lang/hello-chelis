# `src/nautilus/`: numerical methods

A tour of [Nautilus](https://github.com/Chelis-Lang/nautilus), a scipy-like
numerics package written in Chelis. Because its methods are ordinary Chelis
functions, they compose with the rest of the language like any other code.

| File | Module | What it shows |
|---|---|---|
| [`specialfunctions.ch`](specialfunctions.ch) | `Nautilus.Special` | `erf`, `erfc`, `erfinv`, `log_gamma`, Bessel `J0` |
| [`distributions.ch`](distributions.ch) | `Nautilus.Distributions` | normal pdf / cdf / quantile, exponential cdf |
| [`linalg.ch`](linalg.ch) | `Nautilus.LinAlg` | `matvec`, inner product, L2 norm, `solve_2x2` |
| [`stats.ch`](stats.ch) | `Nautilus.Stats` | mean, variance, std, median, quantile, correlation |
| [`info.ch`](info.ch) | `Nautilus.Info` | Shannon entropy and KL divergence |
| [`distance.ch`](distance.ch) | `Nautilus.Distance` | Euclidean, Manhattan, Chebyshev, cosine |
| [`roots.ch`](roots.ch) | `Nautilus.Roots` | bisection, Newton, and Brent on sqrt(2) |
| [`integration.ch`](integration.ch) | `Nautilus.Integrate` | trapezoid, Simpson, and 5-point Gauss-Legendre on the integral of sin from 0 to pi |
| [`odenutilus.ch`](odenutilus.ch) | `Nautilus.Ode` | Euler and RK4 on dy/dt = -y |
| [`sde.ch`](sde.ch) | `Nautilus.Sde` | Euler-Maruyama with the noise set to zero |
| [`interpolation.ch`](interpolation.ch) | `Nautilus.Interpolation` | linear and cubic Hermite interpolation |
| [`optimize.ch`](optimize.ch) | `Nautilus.Optim` | golden section, Brent, and Newton on (x-3)^2 + 7, with SMT bounds on the objective |
| [`hypothesis.ch`](hypothesis.ch) | `Nautilus.Testing` | z and one-sample t statistics, two-sided p-values |
| [`curvefit.ch`](curvefit.ch) | `Nautilus.CurveFit` | one-parameter Levenberg-Marquardt |

Each file has a test of the same name under [`tests/nautilus/`](../../tests/nautilus/).
The full API is documented in the Nautilus book (`docs/book/` in the
[Nautilus repository](https://github.com/Chelis-Lang/nautilus)).

## Notes

- Module names differ from scipy's: ODEs are `Nautilus.Ode`, SDEs
  `Nautilus.Sde`, hypothesis tests `Nautilus.Testing`, and the minimizers
  `Nautilus.Optim`. (`Nautilus.Optimize` also exists, as a higher-level
  front end over `Optim` and `Roots`.)
- These examples use `f32`, so expect about 6 to 7 significant digits.
  Some Nautilus functions, including `Nautilus.Special.gamma`, accept `f64`;
  the remaining precision gaps are tracked in
  [nautilus#70](https://github.com/Chelis-Lang/nautilus/issues/70).
- `gauss_legendre_5` requires `n_points = 5` and traps for another order
  ([positive case](https://github.com/Chelis-Lang/nautilus/blob/v0.7.58/tests/integrate.ch),
  [rejection case](https://github.com/Chelis-Lang/nautilus/blob/v0.7.58/tests_neg/integrate/gauss_legendre_5_n_points_neg.ch)).
  Arbitrary-order quadrature is tracked in
  [nautilus#104](https://github.com/Chelis-Lang/nautilus/issues/104).
- `Nautilus.Signal` is skipped: its transforms and filters return
  NaN ([nautilus#81](https://github.com/Chelis-Lang/nautilus/issues/81)).
