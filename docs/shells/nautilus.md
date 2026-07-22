# `nautilus`

The scipy-equivalent shell. Pure Chelis (no C FFI), so AD flows through
numerical methods via tensor-op composition. Currently `f32`-only;
learner examples use tolerances appropriate to 6–7 significant digits.

Pinned to `0.7.34`. Reef declaration in our [`reef.toml`](../../reef.toml).

## What's here

| Module | Surface |
|---|---|
| `Nautilus.Special` | `erf`, `erfc`, `erfinv`, `gamma`, `log_gamma`, `digamma`, `trigamma`, `beta`, `lbeta`, Bessel `J0`/`J1`/`Y0`/`Y1`/`I0`/`I1`/`K0`/`K1`, Airy `Ai`/`Bi`, elliptic `K`/`E` |
| `Nautilus.Distributions` | `Normal`, `LogNormal`, `Uniform`, `Exponential`, `Gamma`, `Chi2`, `StudentT`, `Poisson`, `Binomial`, `Beta`, `F`, `Weibull` — `pdf`, `cdf`, `inv`, `sample` |
| `Nautilus.LinAlg` | `transpose`, `matmul`, `gram`, `det` (2x2, 3x3), `inverse`, `solve`, `eigvals`, `cholesky` (2x2 + general), `cg` (SPD CG) |
| `Nautilus.Stats` | `mean`, `var`, `std`, `skew`, `kurt`, `median`, `quantile`, `percentile`, `trim_mean`, `cov`, `corr` |
| `Nautilus.Distance` | Euclidean, Manhattan, Chebyshev, cosine, Mahalanobis |
| `Nautilus.Roots` | `bisect`, `newton`, `brent` |
| `Nautilus.Ode` | `euler_step` / `euler_solve`, `rk4_step` / `rk4_solve`, `rk45_endpoint` |
| `Nautilus.Sde` | `euler_maruyama`, `milstein` (caller-supplied noise) |
| `Nautilus.Integrate` | `trapezoid`, `simpson`, `gauss_legendre`, `adaptive_simpson`, `romberg`, `gauss_hermite`, `gauss_laguerre` |
| `Nautilus.Testing` | z / t / chi-squared statistics, p-values, CIs |
| `Nautilus.Optimize` | `golden_section`, `brent_minimize`, `gradient_descent`, `newton_min` |
| `Nautilus.Interpolate` | `linear_uniform`, `linear_sorted`, `cubic_hermite` |
| `Nautilus.CurveFit` | single-parameter Levenberg-Marquardt |

`Nautilus.Signal` is typed-stub-only pending upstream complex-number
support — examples here skip it.

## Examples in this repo

See [`src/nautilus/`](../../src/nautilus/) — catalog at
[`src/nautilus/README.md`](../../src/nautilus/README.md).

The Black-Scholes capstone at
[`src/capstone/blackscholes.ch`](../../src/capstone/blackscholes.ch)
calls `Nautilus.Distributions.normal_cdf`. Call-price execution is pinned;
`delta`/`vega` remain an expected native blocker because grad encounters a
tensor-bool conditional inside that call graph. The corresponding LaTeX
input lives at [`octant/black_scholes_d1.tex`](../../octant/black_scholes_d1.tex).
