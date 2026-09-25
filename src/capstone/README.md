# `src/capstone/`: combining the pieces

Larger examples that combine the language with one or more packages. Read
these last.

| File | Uses | What it shows |
|---|---|---|
| [`blackscholes.ch`](blackscholes.ch) | `nautilus` | the Black-Scholes call price, and its delta and vega via `grad`. The same `d_1` in LaTeX is [`octant/black_scholes_d1.tex`](../../octant/black_scholes_d1.tex). |
| [`linreg.ch`](linreg.ch) | `chelis-std` | linear regression: prediction, MSE loss, and one SGD step using `grad` |
| [`mlpipeline.ch`](mlpipeline.ch) | `coral`, `nautilus` | a frame of prices and cities, a grouped mean, and summary statistics |
| [`transformerblock.ch`](transformerblock.ch) | `chelis-std` | single-head self-attention, a residual connection, and a feed-forward layer, with every shape in the type |

## What is tested

- `blackscholes.ch`: the call price, delta, and vega at the money, against
  analytic values, in [`tests/capstone/blackscholes.ch`](../../tests/capstone/blackscholes.ch).
- `mlpipeline.ch`: [`tests/capstone/mlpipeline.ch`](../../tests/capstone/mlpipeline.ch).
- `linreg.ch` and `transformerblock.ch`: type-checked by `chelis check`, with
  no runtime test yet.

The Black-Scholes Greeks run under `chelis test` but cannot yet be compiled
to C as part of the package
([chelis#2379](https://github.com/Chelis-Lang/chelis/issues/2379)); the
compiled `grad` examples are in [`verify/`](../../verify/).
