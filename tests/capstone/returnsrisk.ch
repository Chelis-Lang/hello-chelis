module Hello.Tests.Capstone.ReturnsRisk
import Hello.Capstone.ReturnsRisk (simple_returns, tickers_covered, sharpe_ratio, portfolio_sharpe, rolling_volatility, parametric_var)
import Std.Test (assert_eq, assert_close)
def rising() -> tensor[5, f32] = to_tensor([cast(0.01, f32), cast(0.02, f32), cast(0.03, f32), cast(0.04, f32), cast(0.05, f32)])
def flat_mean() -> tensor[5, f32] = to_tensor([cast(-0.02, f32), cast(0.01, f32), cast(-0.01, f32), cast(0.02, f32), cast(0.0, f32)])
def test_simple_returns() -> unit ! { Test } = {
  rets = simple_returns([cast(100.0, f32), cast(110.0, f32), cast(99.0, f32)])
  _ = assert_eq(len(rets), cast(2, i64), "n prices give n-1 returns")
  _ = assert_close(index(rets, cast(0, i64)), cast(0.1, f32), cast(1e-6, f32), "100 -> 110 is +10%")
  assert_close(index(rets, cast(1, i64)), cast(-0.1, f32), cast(1e-6, f32), "110 -> 99 is -10%")
}
def test_tickers_covered() -> unit ! { Test } = {
  rets = to_tensor([cast(0.01, f32), cast(0.02, f32), cast(-0.01, f32), cast(0.03, f32)])
  assert_eq(tickers_covered(["aapl", "msft", "aapl", "msft"], rets), cast(2, i64), "two tickers")
}
def test_sharpe_ratio() -> unit ! { Test } = assert_close(sharpe_ratio(rising(), cast(0.0, f32)), cast(1.8973666, f32), cast(0.001, f32), "mean 0.03 / std 0.0158")
def test_portfolio_sharpe_through_frame() -> unit ! { Test } = assert_close(portfolio_sharpe(["a", "a", "a", "a", "a"], rising(), cast(0.0, f32)), cast(1.8973666, f32), cast(0.001, f32), "frame column agrees with tensor")
def test_rolling_volatility() -> unit ! { Test } = {
  out = to_list(rolling_volatility(rising(), cast(3, i64)))
  assert_close(index(out, cast(2, i64)), cast(0.01, f32), cast(0.0001, f32), "window std of 0.01,0.02,0.03")
}
def test_parametric_var_95() -> unit ! { Test } = assert_close(parametric_var(flat_mean(), cast(0.95, f32)), cast(0.0260074, f32), cast(0.0005, f32), "1.645 sigma loss at 95%")
