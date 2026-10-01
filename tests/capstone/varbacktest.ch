module Hello.Tests.Capstone.VarBacktest
import Hello.Capstone.VarBacktest (sample_returns, to_losses, rolling_forecasts, adaptive_forecasts, exceptions, tail_risk, kupiec, christoffersen)
import Hello.Capstone.ReturnsRisk (parametric_var)
import Std.Test (assert_close, assert_eq, assert_true)
def losses() -> List[f32] = to_losses(sample_returns())
def realized() -> List[f32] = skip(losses(), cast(100, i64))
def test_tail_risk() -> unit ! { Test } = {
  r = tail_risk(losses())
  _ = assert_close(r.0, cast(0.025612, f32), cast(0.00001, f32), "historical VaR, linear-interpolated quantile")
  _ = assert_close(r.1, cast(0.03512, f32), cast(0.00001, f32), "historical CVaR")
  _ = assert_close(r.2, cast(0.025762, f32), cast(0.00001, f32), "parametric VaR")
  assert_close(r.3, cast(0.03231, f32), cast(0.00001, f32), "parametric CVaR")
}
def test_parametric_var_matches_returnsrisk() -> unit ! { Test } = assert_close(tail_risk(losses()).2, parametric_var(to_tensor(sample_returns()), cast(0.95, f32)), cast(1e-6, f32), "two conventions, one VaR")
def test_rolling_historical_fails_its_backtest() -> unit ! { Test } = {
  count = exceptions(realized(), rolling_forecasts(losses()))
  _ = assert_eq(count, cast(18, i64), "the static window lags the regime change")
  _ = assert_close(kupiec(count, cast(200, i64)), cast(5.502, f32), cast(0.01, f32), "Kupiec rejects above 3.841")
  cc = christoffersen(realized(), rolling_forecasts(losses()))
  _ = assert_close(cc.0, cast(9.088, f32), cast(0.01, f32), "conditional coverage")
  assert_true(cc.1, "rejected")
}
def test_ewma_passes_its_backtest() -> unit ! { Test } = {
  count = exceptions(realized(), adaptive_forecasts(sample_returns()))
  _ = assert_eq(count, cast(13, i64), "the adaptive model keeps up")
  _ = assert_close(kupiec(count, cast(200, i64)), cast(0.869, f32), cast(0.01, f32), "Kupiec passes")
  cc = christoffersen(realized(), adaptive_forecasts(sample_returns()))
  _ = assert_close(cc.0, cast(2.688, f32), cast(0.01, f32), "conditional coverage")
  assert_true(not(cc.1), "not rejected")
}
