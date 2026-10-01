module Hello.Tests.Capstone.ReturnsRisk
import Hello.Capstone.ReturnsRisk (simple_returns, tickers_covered, sharpe_ratio, portfolio_sharpe, rolling_volatility, parametric_var)
import Std.Test (assert_eq, assert_close)
def rising() -> tensor[5, f32] = to_tensor([0.01f32, 0.02f32, 0.03f32, 0.04f32, 0.05f32])
def flat_mean() -> tensor[5, f32] = to_tensor([-0.02f32, 0.01f32, -0.01f32, 0.02f32, 0.0f32])
def test_simple_returns() -> unit ! { Test } = {
  rets = simple_returns([100.0f32, 110.0f32, 99.0f32])
  _ = assert_eq(len(rets), 2i64, "n prices give n-1 returns")
  _ = assert_close(index(rets, 0i64), 0.1f32, 1e-6f32, "100 -> 110 is +10%")
  assert_close(index(rets, 1i64), -0.1f32, 1e-6f32, "110 -> 99 is -10%")
}
def test_tickers_covered() -> unit ! { Test } = {
  rets = to_tensor([0.01f32, 0.02f32, -0.01f32, 0.03f32])
  assert_eq(tickers_covered(["aapl", "msft", "aapl", "msft"], rets), 2i64, "two tickers")
}
def test_sharpe_ratio() -> unit ! { Test } = assert_close(sharpe_ratio(rising(), 0.0f32), 1.8973666f32, 0.001f32, "mean 0.03 / std 0.0158")
def test_portfolio_sharpe_through_frame() -> unit ! { Test } = assert_close(portfolio_sharpe(["a", "a", "a", "a", "a"], rising(), 0.0f32), 1.8973666f32, 0.001f32, "frame column agrees with tensor")
def test_rolling_volatility() -> unit ! { Test } = {
  out = to_list(rolling_volatility(rising(), 3i64))
  assert_close(index(out, 2i64), 0.01f32, 0.0001f32, "window std of 0.01,0.02,0.03")
}
def test_parametric_var_95() -> unit ! { Test } = assert_close(parametric_var(flat_mean(), 0.95f32), 0.0260074f32, 0.0005f32, "1.645 sigma loss at 95%")
