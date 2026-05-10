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
| `chelis test tests/capstone/` | runtime assertions for `blackscholes::call_atm`, `mlpipeline::*`, `transformerblock::block_module_loads` |
| C-backend full lowering | [`verify/grad_works.ch`](../../verify/grad_works.ch), [`verify/grad_quadratic.ch`](../../verify/grad_quadratic.ch) prove `grad` reaches native execution |

## Why some capstone tests are smoke-only

The IR evaluator at v0.7.3 doesn't yet lower `grad` for the host
runtime, so test files like `tests/capstone/blackscholes.ch` exercise
`call_price` (which doesn't use `grad`) but not `delta` / `vega`
(which do). The `chelis check` pass validates the full grad
definition at type-system level; the runtime exercise of grad lives
in [`verify/`](../../verify/), where files build through the C
backend, link against `libchelis_runtime.a` + OpenBLAS, and execute.

See [`docs/discrepancies.md`](../../docs/discrepancies.md) for the
full inventory of compiler/runtime gaps and the workarounds used
across this corpus.
