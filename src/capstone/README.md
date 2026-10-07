# `src/capstone/`: combining the pieces

Larger examples that combine the language with one or more packages. Read
these last.

| File | Uses | What it shows |
|---|---|---|
| [`blackscholes.ch`](blackscholes.ch) | `nautilus` | Black-Scholes call price + Greeks (delta, vega) via `grad`. |
| [`linreg.ch`](linreg.ch) | `chelis-std` | Linear regression: design matrix, `predict`, MSE loss, single SGD step. |
| [`returnsrisk.ch`](returnsrisk.ch) | `coral` + `nautilus` | Returns and risk: prices → simple returns → a Coral frame grouped by ticker → Sharpe ratio, rolling volatility (`Coral.Window`), and parametric value-at-risk from the Nautilus normal quantile. |
| [`yieldcurve.ch`](yieldcurve.ch) | `shoals` | Bootstrap a zero curve from par yields (`Shoals.Curves`), price a bond on it, and measure DV01 and key-rate risk by bump-and-reprice. Also shows what happens when the bootstrap's precondition (consecutive annual pillars) is broken: no error, just a wrong curve. |
| [`americanput.ch`](americanput.ch) | `shoals` + `nautilus` | One American put priced three independent ways: a CRR binomial tree (`Shoals.Trees`), Crank-Nicolson finite differences (`Shoals.Pde`), and the Barone-Adesi-Whaley approximation, built from Nautilus `brent` and `normal_cdf`. The European price (`Shoals.Pricing`) is the lower bound. |
| [`varbacktest.ch`](varbacktest.ch) | `shoals` + `coral` + `nautilus` | Historical and parametric VaR/CVaR (`Shoals.Risk`), then a backtest: a rolling 100-day historical model against an EWMA model (Coral `ewm`), scored with the Kupiec and Christoffersen tests (`Shoals.RiskExt`) across a volatility regime change. |

## What is tested

- `blackscholes.ch`: the call price, delta, and vega at the money, against
  analytic values, in [`tests/capstone/blackscholes.ch`](../../tests/capstone/blackscholes.ch).
- `returnsrisk.ch`: [`tests/capstone/returnsrisk.ch`](../../tests/capstone/returnsrisk.ch).
- `yieldcurve.ch`: the par-coupon bond prices at par, the 5y zero, DV01 and
  the 5y key-rate sensitivity, and the gapped-pillar curve's wrong 5y zero, in
  [`tests/capstone/yieldcurve.ch`](../../tests/capstone/yieldcurve.ch).
- `americanput.ch`: the European price, the early-exercise premium, the
  50-step tree's exact value (6.073728) and its distance from a 2,000-step
  reference, the critical price, the Barone-Adesi-Whaley price, and the
  deep in-the-money put that exercises at once, in
  [`tests/capstone/americanput.ch`](../../tests/capstone/americanput.ch).
  The finite-difference pricer is shown in the lesson but not tested (a
  50 x 50 grid gives 6.125, 200 x 200 gives 6.0895).
- `varbacktest.ch`: the full-sample VaR and CVaR; the parametric VaR equals
  `returnsrisk.ch`'s `parametric_var`; the historical model fails its
  backtest (18 exceptions where 10 are expected) and the EWMA model passes
  (13), in [`tests/capstone/varbacktest.ch`](../../tests/capstone/varbacktest.ch).
- `linreg.ch`: type-checked by `chelis check`, with no runtime test yet.

The Black-Scholes Greeks run under `chelis test` and through the compiled
package C API in [`tests/test_c_backend.py`](../../tests/test_c_backend.py).

Every expected value in the Shoals capstone tests was derived independently
of Chelis, so the tests check the libraries rather than restate their
output. The data is synthetic and deterministic: the VaR returns are normal
shocks drawn from a golden-ratio sequence through `normal_inv_cdf`, with no
random keys. `shoals`, like `nautilus`, works in f32, so the tolerances are
set for single precision.

Conventions in the Shoals capstones:

- `yieldcurve.ch`: annual coupons, face value 1, continuously compounded
  zero rates. `key_rate_sensitivity` takes a 0-based pillar index, so 4 is
  the 5y pillar.
- `americanput.ch`: no dividends. The finite-difference grid runs to 4 x the
  strike. The Barone-Adesi-Whaley exponent is
  q1 = (-(m - 1) - sqrt((m - 1)^2 + 4m / (1 - exp(-rt)))) / 2 with
  m = 2r / sigma^2, and the critical price is the root of the
  smooth-pasting condition, found with `brent` on [0.2 x strike, strike].
- `varbacktest.ch`: 95% VaR backtested over days 100-299, so 10 exceptions
  are expected. Each day's forecast uses only data before that day. The
  EWMA model is RiskMetrics (lambda 0.94, so `ewm` alpha 0.06). At 95% the
  Kupiec statistic rejects above 3.841 (1 dof) and Christoffersen's
  conditional coverage above 5.991 (2 dof); `christoffersen` also returns
  the verdict.
