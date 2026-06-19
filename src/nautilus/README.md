# `src/nautilus/` — numerical methods

Tour of [Nautilus](https://github.com/Chelis-Lang/nautilus), the
scipy-equivalent shell. Pure Chelis (no C FFI), so AD flows through
every numerical method via tensor-op composition.

Pinned to `nautilus` v0.7.26. f32-only; 6–7 significant digits of
precision.

## Files

| File | Surface | Notes |
|---|---|---|
| [`specialfunctions.ch`](specialfunctions.ch) | `Nautilus.Special` | `erf`, `erfc`, `erfinv`, `gamma`, `log_gamma`, Bessel `J0` |
| [`distributions.ch`](distributions.ch) | `Nautilus.Distributions` | Normal pdf/cdf/quantile, Exponential at half-life |
| [`linalg.ch`](linalg.ch) | `Nautilus.LinAlg` | L2 norm, inner product, `solve_2x2` |
| [`stats.ch`](stats.ch) | `Nautilus.Stats` | sample mean/var/std/median/correlation |
| [`distance.ch`](distance.ch) | `Nautilus.Distance` | Euclidean / Manhattan / Chebyshev / cosine / self-distance |
| [`roots.ch`](roots.ch) | `Nautilus.Roots` | `bisect` / `brent` / `newton` on √2 |
| [`integration.ch`](integration.ch) | `Nautilus.Integrate` | trapezoid / Simpson / Gauss-Legendre on ∫₀^π sin |
| [`odenutilus.ch`](odenutilus.ch) | `Nautilus.Ode` | Euler / RK4 on dy/dt = -y |
| [`sde.ch`](sde.ch) | `Nautilus.Sde` | Euler-Maruyama, GBM zero-noise step |
| [`interpolation.ch`](interpolation.ch) | `Nautilus.Interpolate` | linear at node / midpoint, Hermite mid / endpoint |
| [`optimize.ch`](optimize.ch) | `Nautilus.Optimize` | golden section / Brent / Newton on (x-3)² + 7 |
| [`hypothesis.ch`](hypothesis.ch) | `Nautilus.Testing` | z / t one-sample, p-values |
| [`curvefit.ch`](curvefit.ch) | `Nautilus.CurveFit` | scalar Levenberg-Marquardt, exp-decay and linear |

The full export list lives in
[`docs/shells/nautilus.md`](../../docs/shells/nautilus.md).

## What's verified

| Lane | Coverage |
|---|---|
| `chelis check src/nautilus/<file>.ch` | every file passes with fitness 1.0 |
| `chelis test tests/nautilus/` | 47 runtime assertions across 13 modules |
| Surf-Deep equivalence | every `.ch` paired with a machine-generated `.dp` |

## Module naming gotchas

Some Nautilus module names differ from common scipy conventions:
- `Nautilus.Ode` (not `ODE`)
- `Nautilus.Sde` (not `SDE`)
- `Nautilus.Testing` (not `Hypothesis`)

The `gauss_legendre_5` integrator takes a `n_points` argument it
ignores — pass any int. `lm_scalar_1param` is the scalar-output form
of the LM curve fit; tensor-output variants exist but require
extracting via `tensor_to_scalar` for use with `assert_close`.
