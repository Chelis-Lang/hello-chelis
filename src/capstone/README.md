# `src/capstone/`: combining the pieces

Larger examples that combine the language with one or more packages. Read
these last.

| File | Uses | What it shows |
|---|---|---|
| [`blackscholes.ch`](blackscholes.ch) | `nautilus` | Black-Scholes call price + Greeks (delta, vega) via `grad`. Mirrors the LaTeX in [`octant/black_scholes_d1.tex`](../../octant/black_scholes_d1.tex). |
| [`linreg.ch`](linreg.ch) | `chelis-std` | Linear regression: design matrix, `predict`, MSE loss, single SGD step. |
| [`returnsrisk.ch`](returnsrisk.ch) | `coral` + `nautilus` | Returns and risk: prices → simple returns → a Coral frame grouped by ticker → Sharpe ratio, rolling volatility (`Coral.Window`), and parametric value-at-risk from the Nautilus normal quantile. |

## What is tested

- `blackscholes.ch`: the call price, delta, and vega at the money, against
  analytic values, in [`tests/capstone/blackscholes.ch`](../../tests/capstone/blackscholes.ch).
- `returnsrisk.ch`: [`tests/capstone/returnsrisk.ch`](../../tests/capstone/returnsrisk.ch).
- `linreg.ch`: type-checked by `chelis check`, with no runtime test yet.

The Black-Scholes Greeks run under `chelis test` but cannot yet be compiled
to C as part of the package
([chelis#2379](https://github.com/Chelis-Lang/chelis/issues/2379)); the
compiled `grad` examples are in [`verify/`](../../verify/).
