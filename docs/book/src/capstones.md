# Read a larger calculation

The hello-chelis repository ends with three capstone modules that combine
the ideas from the [five lessons](curriculum.md): explicit
shapes, borrowing, and `grad`. Each section below gives the module's
signatures, quotes the key function, explains what it computes, and calls it
with inputs you can check by hand. The outputs are from `chelis eval`.

## Set up the package

The capstones import the hello-chelis package and its dependencies:
[nautilus](https://chelis.ch/docs/nautilus/) for the normal distribution and statistics, and
[coral](https://chelis.ch/docs/coral/) for dataframes. The package's `reef.toml` names the
exact compiler version it builds with; install that version first (see
[Install](https://chelis.ch/docs/chelis/install/)). Then clone the release these examples
quote and install the dependency versions its lockfile records:

```sh
git clone --branch v0.1.12 https://github.com/Chelis-Lang/hello-chelis.git
cd hello-chelis
chelis reef install --from-lockfile
```

`chelis reef install --from-lockfile` downloads each dependency recorded in
`reef.lock` and checks its hash. Save each example file below in the root
of the checkout, next to `reef.toml`, so its `import` resolves against the
package, then evaluate it:

```sh
chelis eval --file linreg_call.ch
```

The repository's tests call the Black-Scholes and returns functions with
the same inputs used below:

```sh
chelis test tests/capstone/
```

```text
tests/capstone/blackscholes.ch
  test_call_atm ................. PASS
  test_delta_atm ................ PASS
  test_vega_atm ................. PASS
tests/capstone/returnsrisk.ch
  test_simple_returns ........... PASS
  test_tickers_covered .......... PASS
  test_sharpe_ratio ............. PASS
  test_portfolio_sharpe_through_frame PASS
  test_rolling_volatility ....... PASS
  test_parametric_var_95 ........ PASS

9 passed, 0 failed
```

## Linear regression

Module `Hello.Capstone.LinReg` ([`linreg.ch`](https://github.com/Chelis-Lang/hello-chelis/blob/v0.1.12/src/capstone/linreg.ch))
fits the linear model `y = x w + b` to 64 observations of 64 features.

| Function | Signature | Computes |
|---|---|---|
| `predict` | `(x: tensor[64, 64, f32], w: tensor[64, 1, f32], b: tensor[1, f32]) -> tensor[64, 1, f32]` | `matmul(x, w) + b`, one prediction per row |
| `mse_loss` | `(x: tensor[64, 64, f32], y: tensor[64, 1, f32], w: tensor[64, 1, f32], b: tensor[1, f32]) -> tensor[f32]` | Sum of squared errors, a rank-0 tensor |
| `sgd_step` | `(x, y, w, b, lr: f32) -> (tensor[64, 1, f32], tensor[1, f32])` | One gradient-descent update of `w` and `b` |

The shapes are fixed numbers, not dimension variables, so a call with 100
rows or 10 features fails the shape check before anything runs. To fit
other sizes, copy the module and change the numbers, or replace them with
dimension variables as in `add_vec[n]`.

### `predict`: an explicit bias broadcast

```chelis-surf
def predict(x: tensor[64, 64, f32], w: tensor[64, 1, f32], b: tensor[1, f32]) -> tensor[64, 1, f32] = x |> matmul(w) |> add(insert(b, 0, 64i64))
```

`matmul` takes `[64, 64]` by `[64, 1]` to `[64, 1]`. The bias has shape
`[1]`, and `add` does not broadcast, so `insert(b, 0, 64i64)` adds a new
axis at position 0 with size 64. That turns `[1]` into `[64, 1]` by
repeating the single bias value down the rows, and the two `[64, 1]`
tensors add element by element.

### `mse_loss`: squared errors, summed

```chelis-surf
def mse_loss(x: tensor[64, 64, f32], y: tensor[64, 1, f32], w: tensor[64, 1, f32], b: tensor[1, f32]) -> tensor[f32] = {
  pred = predict(x, w, b)
  err = sub(pred, y)
  err_copy = err
  sum(sum(mul(err, err_copy), 1), 0)
}
```

`err` is `[64, 1]`. `mul` squares each error, `sum(..., 1)` removes the
column axis to give `[64]`, and `sum(..., 0)` removes the row axis to give
a rank-0 tensor. Despite the name, the function does not divide by 64: the
loss is the sum of squared errors, and it grows with the number of rows.

### `sgd_step`: two gradients

```chelis-surf
def sgd_step(x: tensor[64, 64, f32], y: tensor[64, 1, f32], w: tensor[64, 1, f32], b: tensor[1, f32], lr: f32) -> (tensor[64, 1, f32], tensor[1, f32]) = {
  dw = grad(mse_loss, wrt=w)(x, y, w, b)
  db = grad(mse_loss, wrt=b)(x, y, w, b)
  lr_t = to_tensor([lr])
  new_w = w |> sub(mul(insert(lr_t, 0, 64i64), dw))
  new_b = sub(b, mul(lr_t, db))
  (new_w, new_b)
}
```

`grad(mse_loss, wrt=w)` differentiates the loss with respect to the weights
and returns a `[64, 1]` gradient; `wrt=b` gives a `[1]` gradient. The step
turns the scalar `lr` into a one-element tensor, inserts a row axis for the
weight update, and returns the tuple `(new_w, new_b)`.

### Call it

Every feature is 1.0, every weight 0.5, the bias 1.0, and every target 30.0.
Each prediction is 64 × 0.5 + 1 = 33, each error is 3, and the loss is
64 × 9 = 576. Each weight's gradient is the sum over 64 rows of 2 × 3 × 1,
which is 384, and so is the bias gradient. A step with `lr = 0.001` moves
the weights to 0.5 - 0.384 = 0.116 and the bias to 1 - 0.384 = 0.616.

Save as `linreg_call.ch`:

```chelis-surf
import Hello.Capstone.LinReg (predict, mse_loss, sgd_step)
def features() -> tensor[64, 64, f32] = expand(insert(to_tensor([1.0f32]), 0, 64i64), 1, 64i64)
def weights() -> tensor[64, 1, f32] = insert(to_tensor([0.5f32]), 0, 64i64)
def targets() -> tensor[64, 1, f32] = insert(to_tensor([30.0f32]), 0, 64i64)
pred = predict(features(), weights(), to_tensor([1.0f32]))
loss = mse_loss(features(), targets(), weights(), to_tensor([1.0f32]))
step = sgd_step(features(), targets(), weights(), to_tensor([1.0f32]), 0.001f32)
```

`features` builds the `[64, 64]` matrix from one value: `insert` makes it
`[64, 1]`, and `expand` widens the size-one axis 1 to 64.

```text
features = tensor(shape=[64, 64], data=[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, ...])
weights = tensor(shape=[64, 1], data=[0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, ...])
targets = tensor(shape=[64, 1], data=[30.0, 30.0, 30.0, 30.0, 30.0, 30.0, 30.0, 30.0, 30.0, 30.0, 30.0, 30.0, 30.0, 30.0, 30.0, 30.0, 30.0, 30.0, 30.0, 30.0, 30.0, 30.0, 30.0, 30.0, 30.0, 30.0, 30.0, 30.0, 30.0, 30.0, 30.0, 30.0, ...])
pred = tensor(shape=[64, 1], data=[33.0, 33.0, 33.0, 33.0, 33.0, 33.0, 33.0, 33.0, 33.0, 33.0, 33.0, 33.0, 33.0, 33.0, 33.0, 33.0, 33.0, 33.0, 33.0, 33.0, 33.0, 33.0, 33.0, 33.0, 33.0, 33.0, 33.0, 33.0, 33.0, 33.0, 33.0, 33.0, ...])
loss = 576.0
step.0 = tensor(shape=[64, 1], data=[0.116, 0.116, 0.116, 0.116, 0.116, 0.116, 0.116, 0.116, 0.116, 0.116, 0.116, 0.116, 0.116, 0.116, 0.116, 0.116, 0.116, 0.116, 0.116, 0.116, 0.116, 0.116, 0.116, 0.116, 0.116, 0.116, 0.116, 0.116, 0.116, 0.116, 0.116, 0.116, ...])
step.1 = tensor(shape=[1], data=[0.616])
```

`step.0` is the updated weight vector and `step.1` the updated bias. Because
the loss is a sum, its gradient is 64 times the gradient of a mean loss.
Choose the learning rate for that scale: here the first step overshoots the
fit (predictions go from 33 to 64 × 0.116 + 0.616 = 8.04).

**Try it:** set every target to 33.0. The loss becomes 0.0, both gradients
are zero, and `sgd_step` returns the weights and bias unchanged.

## Option pricing

Module `Hello.Capstone.BlackScholes` ([`blackscholes.ch`](https://github.com/Chelis-Lang/hello-chelis/blob/v0.1.12/src/capstone/blackscholes.ch))
prices a European call with the Black-Scholes formula and gets two Greeks by
differentiating the price function.

| Function | Signature | Computes |
|---|---|---|
| `call_price` | `(s: f32, k: f32, r: f32, sigma: f32, t: f32) -> f32` | Call price |
| `delta` | same | Derivative of the price with respect to `s` |
| `vega` | same | Derivative of the price with respect to `sigma` |

The inputs, in order:

- `s`: spot price of the underlying, and `k`: strike, in the same currency.
- `r`: risk-free rate as a decimal (0.05 for 5%), continuously compounded:
  the strike is discounted by `exp(-r t)`.
- `sigma`: volatility as a decimal (0.2 for 20%).
- `t`: time to expiry. `r` and `sigma` must be quoted per the same unit as
  `t`; with annual rates and volatilities, `t` is in years.

Keep `s`, `k`, `sigma`, and `t` positive: `d1` takes `log(s / k)` and
divides by `sigma * sqrt(t)`. All arithmetic is `f32`, about seven
significant digits.

### `call_price`

```chelis-surf
def d1(s: f32, k: f32, r: f32, sigma: f32, t: f32) -> f32 = {
  num = add(log(div(s, k)), mul(add(r, mul(0.5f32, mul(sigma, sigma))), t))
  den = mul(sigma, sqrt(t))
  div(num, den)
}
def d2(s: f32, k: f32, r: f32, sigma: f32, t: f32) -> f32 = sub(d1(s, k, r, sigma, t), mul(sigma, sqrt(t)))
def call_price(s: f32, k: f32, r: f32, sigma: f32, t: f32) -> f32 = {
  d_1 = d1(s, k, r, sigma, t)
  d_2 = d2(s, k, r, sigma, t)
  discount = exp(neg(mul(r, t)))
  sub(mul(s, normal_cdf(d_1, 0.0f32, 1.0f32)), mul(mul(k, discount), normal_cdf(d_2, 0.0f32, 1.0f32)))
}
```

This is the textbook formula:

```text
d1    = (ln(s / k) + (r + sigma^2 / 2) * t) / (sigma * sqrt(t))
d2    = d1 - sigma * sqrt(t)
price = s * N(d1) - k * exp(-r * t) * N(d2)
```

N is the standard normal CDF, Nautilus's `normal_cdf(x, mean, std)` with
mean 0 and standard deviation 1. `d1` and `d2` are internal helpers; the
module exports only `call_price`, `delta`, and `vega`.

### `delta` and `vega`

```chelis-surf
def delta(s: f32, k: f32, r: f32, sigma: f32, t: f32) -> f32 = grad(call_price, wrt=s)(s, k, r, sigma, t)
def vega(s: f32, k: f32, r: f32, sigma: f32, t: f32) -> f32 = grad(call_price, wrt=sigma)(s, k, r, sigma, t)
```

No Greek formula is written out. `grad(call_price, wrt=s)` differentiates
the whole price expression, through `log`, `sqrt`, `exp`, and `normal_cdf`,
with respect to `s` and holds the other four inputs fixed. Delta is the
price change per one unit of spot. Vega is per 1.0 of `sigma`, so a vega of
37.52 means about 0.375 per volatility point (0.01).

### Call it

At the money: spot 100, strike 100, 5% rate, 20% volatility, one year. Save
as `bs_call.ch`:

```chelis-surf
import Hello.Capstone.BlackScholes (call_price, delta, vega)
price = call_price(100.0f32, 100.0f32, 0.05f32, 0.2f32, 1.0f32)
d = delta(100.0f32, 100.0f32, 0.05f32, 0.2f32, 1.0f32)
v = vega(100.0f32, 100.0f32, 0.05f32, 0.2f32, 1.0f32)
```

```text
price = 10.450577
d = 0.6368302
v = 37.52404
```

The reference values are 10.4506, 0.63683, and 37.524, and the repository's
tests accept differences of 0.05, 0.001, and 0.01 respectively. By hand:
d1 = (0 + 0.07) / 0.2 = 0.35, so delta is N(0.35) = 0.6368, and vega is
s * sqrt(t) times the normal density at 0.35, 100 × 0.3752.

**Try it:** raise `s` to 101.0. The price rises from 10.4506 to 11.0967, a
change of 0.646: delta's 0.637 plus a little curvature.

## Returns and risk

Module `Hello.Capstone.ReturnsRisk` ([`returnsrisk.ch`](https://github.com/Chelis-Lang/hello-chelis/blob/v0.1.12/src/capstone/returnsrisk.ch))
turns prices into returns and computes per-period risk statistics. The
statistics use `mean_vec` and `std_vec` from Nautilus's
[descriptive statistics](https://chelis.ch/docs/nautilus/stats/descriptive/); the dataframe
functions use a Coral `Frame`, a table of named columns with one row count
(see [Coral](https://chelis.ch/docs/coral/)).

| Function | Signature | Computes |
|---|---|---|
| `simple_returns` | `(prices: List[f32]) -> List[f32]` | `(p[i+1] - p[i]) / p[i]`; n prices give n - 1 returns |
| `returns_frame` | `[n](tickers: List[string], rets: tensor[n, f32]) -> Frame[n]` | A frame with a `"ticker"` string column and a `"ret"` float column |
| `tickers_covered` | `[n](tickers: List[string], rets: tensor[n, f32]) -> i64` | Number of distinct tickers |
| `sharpe_ratio` | `[n](rets: &tensor[n, f32], risk_free: f32) -> f32` | (mean - `risk_free`) / sample standard deviation |
| `portfolio_sharpe` | `[n](tickers: List[string], rets: tensor[n, f32], risk_free: f32) -> f32` | `sharpe_ratio` of the frame's `"ret"` column |
| `rolling_volatility` | `[n](rets: tensor[n, f32], window: i64) -> tensor[n, f32]` | Rolling sample standard deviation over `window` returns |
| `parametric_var` | `[n](rets: &tensor[n, f32], confidence: f32) -> f32` | Normal value at risk, as a positive loss fraction |

### `simple_returns`

```chelis-surf
def simple_returns(prices: List[f32]) -> List[f32] = {
  steps = sub(len(prices), 1i64)
  pairs = zip(take(prices, steps), skip(prices, 1i64))
  map(fn (pair: (f32, f32)) -> div(sub(pair.1, pair.0), pair.0), pairs)
}
```

`take` drops the last price and `skip` drops the first, so `zip` pairs each
price with the next one. Each pair becomes (next - previous) / previous.
The input is a `List`, not a tensor, and its length is a runtime value. A
zero previous price divides by zero: `simple_returns([0.0f32, 1.0f32, 2.0f32])`
returns `[inf, 1.0]`.

### `sharpe_ratio` and `portfolio_sharpe`

```chelis-surf
def sharpe_ratio[n](rets: &tensor[n, f32], risk_free: f32) -> f32 = div(sub(mean_vec(rets), risk_free), std_vec(rets, 1i64))
def portfolio_sharpe[n](tickers: List[string], rets: tensor[n, f32], risk_free: f32) -> f32 = {
  df = returns_frame(tickers, rets)
  sharpe_ratio(get_float_col(df, "ret"), risk_free)
}
```

`std_vec(rets, 1i64)` is the sample standard deviation (divisor n - 1).
`risk_free` is a return for the same period as each observation: with daily
returns, pass the daily risk-free return. The ratio is not annualized. A
single observation has no sample standard deviation, so
`sharpe_ratio(to_tensor([0.01f32]), 0.0f32)` returns `NaN`.

`portfolio_sharpe` builds the frame with `returns_frame`, takes its `"ret"`
column back out as a `tensor[n, f32]` with `get_float_col`, and applies
`sharpe_ratio` to all rows together. It does not compute one ratio per
ticker. `tickers` must have the same length as `rets`: with two tickers
and three returns, evaluation stops with
`error: from_pairs: mismatched column lengths`.

`parametric_var` takes z, the standard normal quantile at 1 - `confidence`
(about -1.645 at 0.95), and returns -(mean + z × sample std). A result of
0.026 means a one-period loss of 2.6% of value at that confidence, under a
normal model of returns. `rolling_volatility` returns `NaN` for the first
`window - 1` positions, where no full window exists yet.

### Call it

The returns 0.01 to 0.05 have mean 0.03 and sample standard deviation
0.0158, so their Sharpe ratio with a zero risk-free rate is 0.03 / 0.0158,
about 1.897. Save as `returns_call.ch`:

```chelis-surf
import Hello.Capstone.ReturnsRisk (simple_returns, tickers_covered, sharpe_ratio, portfolio_sharpe, rolling_volatility, parametric_var)
def rising() -> tensor[5, f32] = to_tensor([0.01f32, 0.02f32, 0.03f32, 0.04f32, 0.05f32])
rets = simple_returns([100.0f32, 110.0f32, 99.0f32])
sharpe = sharpe_ratio(rising(), 0.0f32)
frame_sharpe = portfolio_sharpe(["a", "a", "a", "a", "a"], rising(), 0.0f32)
covered = tickers_covered(["aapl", "msft", "aapl", "msft"], to_tensor([0.01f32, 0.02f32, -0.01f32, 0.03f32]))
vol = rolling_volatility(rising(), 3i64)
var95 = parametric_var(to_tensor([-0.02f32, 0.01f32, -0.01f32, 0.02f32, 0.0f32]), 0.95f32)
```

```text
rising = tensor(shape=[5], data=[0.01, 0.02, 0.03, 0.04, 0.05])
rets = [0.1, -0.1]
sharpe = 1.8973663
frame_sharpe = 1.8973663
covered = 2
vol = tensor(shape=[5], data=[NaN, NaN, 0.01, 0.01, 0.010000001])
var95 = 0.02600753
```

100 to 110 is +10% and 110 to 99 is -10%. The frame path gives the same
Sharpe ratio as the tensor path. Four rows over `aapl` and `msft` cover two
tickers. Each full three-return window, such as 0.01, 0.02, 0.03, has
sample standard deviation 0.01. The last `vol` value shows `f32` rounding
in the seventh digit.

To go from prices to a Sharpe ratio, convert the returns list with
`to_tensor`. Save as `sharpe_from_prices.ch`:

```chelis-surf
import Hello.Capstone.ReturnsRisk (simple_returns, sharpe_ratio)
chained = sharpe_ratio(to_tensor(simple_returns([100.0f32, 110.0f32, 99.0f32, 104.0f32])), 0.0f32)
```

```text
chained = 0.16161945
```

The returns are 0.1, -0.1, and 0.0505, with mean 0.0168 and sample
standard deviation 0.1042.

**Try it:** pass a risk-free return of 0.01 to `sharpe_ratio(rising(), ...)`.
The numerator drops from 0.03 to 0.02, so the ratio falls to about 1.265.
