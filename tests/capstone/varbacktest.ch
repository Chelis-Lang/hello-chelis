module Hello.Tests.Capstone.VarBacktest
import Hello.Capstone.VarBacktest (sample_returns, to_losses, rolling_forecasts, adaptive_forecasts, exceptions, tail_risk, kupiec, christoffersen)
import Hello.Capstone.ReturnsRisk (parametric_var)
import Std.Test (assert_close, assert_eq)
def test_tail_risk() -> unit ! { Test } = {
  r = tail_risk(to_losses(sample_returns()))
  _ = assert_close(r.0, 0.025612f32, 0.00001f32, "historical VaR, linear-interpolated quantile")
  _ = assert_close(r.1, 0.03512f32, 0.00001f32, "historical CVaR")
  _ = assert_close(r.2, 0.025762f32, 0.00001f32, "parametric VaR")
  assert_close(r.3, 0.03231f32, 0.00001f32, "parametric CVaR")
}
-- Shoals works on losses (mean + z * sd); ReturnsRisk works on returns (-(mean + z_0.05 * sd)): the same number
def test_parametric_var_matches_returnsrisk() -> unit ! { Test } = assert_close(tail_risk(to_losses(sample_returns())).2, parametric_var(to_tensor(sample_returns()), 0.95f32), 1e-6f32, "two conventions, one VaR")
-- 200 backtest days at 95%: 10 exceptions expected
def test_rolling_historical_fails_its_backtest() -> unit ! { Test } = {
  losses = to_losses(sample_returns())
  realized = skip(to_losses(sample_returns()), 100i64)
  forecasts = rolling_forecasts(losses)
  count = exceptions(realized, forecasts)
  _ = assert_eq(count, 18i64, "the static window lags the regime change")
  _ = assert_close(kupiec(count, 200i64), 5.502f32, 0.01f32, "Kupiec rejects above 3.841")
  cc = christoffersen(skip(to_losses(sample_returns()), 100i64), rolling_forecasts(to_losses(sample_returns())))
  _ = assert_close(cc.0, 9.088f32, 0.01f32, "conditional coverage")
  assert_eq(cc.1, true, "rejected")
}
def test_ewma_passes_its_backtest() -> unit ! { Test } = {
  realized = skip(to_losses(sample_returns()), 100i64)
  forecasts = adaptive_forecasts(sample_returns())
  count = exceptions(realized, forecasts)
  _ = assert_eq(count, 13i64, "the adaptive model keeps up")
  _ = assert_close(kupiec(count, 200i64), 0.869f32, 0.01f32, "Kupiec passes")
  cc = christoffersen(skip(to_losses(sample_returns()), 100i64), adaptive_forecasts(sample_returns()))
  _ = assert_close(cc.0, 2.688f32, 0.01f32, "conditional coverage")
  assert_eq(cc.1, false, "not rejected")
}
