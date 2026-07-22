# `src/capstone/` — multi-shell integrations

Programs that combine more than one shell into a single end-to-end
example. Read these last; they assume comfort with the basics, std,
and the relevant shells.

## Files

| File | Shells used | Topic |
|---|---|---|
| [`blackscholes.ch`](blackscholes.ch) | `nautilus` | Black-Scholes call price + Greeks (delta, vega) via `grad`. Mirrors the LaTeX in [`octant/black_scholes_d1.tex`](../../octant/black_scholes_d1.tex). |
| [`linreg.ch`](linreg.ch) | `chelis-std` | Linear regression: design matrix, `predict`, MSE loss, single SGD step. |
| [`mlpipeline.ch`](mlpipeline.ch) | `chelis-std` + `coral` + `nautilus` | End-to-end ML: load CSV via Coral → feature engineering → loss → Nautilus statistical evaluation. |
| [`transformerblock.ch`](transformerblock.ch) | `chelis-std` | The primer's transformer-block walkthrough: self-attention with explicit `copy(x)` at every fan-out, residual + layer-norm, MLP. |

## What's verified

| Lane | Coverage |
|---|---|
| `chelis check src/capstone/<file>.ch` | every file passes with fitness 1.0 |
| `chelis test tests/capstone/` | runtime assertions for Black-Scholes call price, LinReg prediction/expand shape, ML pipeline, and transformer block |
| C-backend full lowering | [`verify/grad_quadratic.ch`](../../verify/grad_quadratic.ch) and [`verify/grad_works.ch`](../../verify/grad_works.ch) prove `grad` reaches native execution |

## Current capstone boundary

Direct scalar and tensor `grad` now execute at Chelis `0.16.1`, and the focused
C goldens use the direct form. Black-Scholes `delta`/`vega` still expose a
narrower conditional-lowering defect inside the Nautilus `normal_cdf` call graph;
the exact-value delta case lives in
[`tests_blocked/capstone/blackscholes_grad.ch`](../../tests_blocked/capstone/blackscholes_grad.ch).
See [`docs/discrepancies.md`](../../docs/discrepancies.md) for the observed
per-lane diagnostic.
