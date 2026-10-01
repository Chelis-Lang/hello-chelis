module Hello.Capstone.VarBacktest
import Shoals.Risk (historical_var, historical_cvar, parametric_var, parametric_cvar)
import Shoals.RiskExt (kupiec_pof_statistic_simple, re_christoffersen_cc)
import Coral.Window (ewm)
import Nautilus.Distributions (normal_inv_cdf)
export (daily_return, sample_returns, to_losses, rolling_forecasts, adaptive_forecasts, exceptions, tail_risk, kupiec, christoffersen)
-- deterministic synthetic returns: normal shocks from a golden-ratio sequence,
-- volatility 1% for 150 days then 2% (a regime change the models must face)
def shock(t: i64) -> f32 = {
  x = mul(cast(add(t, 1i64), f32), 0.618034f32)
  normal_inv_cdf(sub(x, cast(cast_trunc(x, i64), f32)), 0.0f32, 1.0f32)
}
def daily_return(t: i64) -> f32 = mul(if lt(t, 150i64) then 0.01f32 else 0.02f32, shock(t))
def sample_returns() -> List[f32] = map(daily_return, range(0i64, 300i64))
def to_losses(rets: List[f32]) -> List[f32] = map(fn (r: f32) -> neg(r), rets)
-- full-sample 95% (VaR, CVaR): historical from the empirical quantile, parametric from a fitted normal
def tail_risk(losses: List[f32]) -> (f32, f32, f32, f32) = (historical_var(to_tensor(losses), 0.95f32), historical_cvar(to_tensor(losses), 0.95f32), parametric_var(to_tensor(losses), 0.95f32), parametric_cvar(to_tensor(losses), 0.95f32))
-- 95% VaR forecasts for days 100-299; the forecast for day t uses only data before day t
def rolling_forecasts(losses: List[f32]) -> List[f32] = map(fn (t: i64) -> historical_var(to_tensor(take(skip(losses, sub(t, 100i64)), 100i64)), 0.95f32), range(100i64, 300i64))
-- RiskMetrics EWMA variance (lambda 0.94, so alpha 0.06) of squared returns
def adaptive_forecasts(rets: List[f32]) -> List[f32] = {
  v = to_list(ewm(to_tensor(map(fn (r: f32) -> mul(r, r), rets)), 0.06f32))
  map(fn (t: i64) -> mul(1.644854f32, sqrt(index(v, sub(t, 1i64)))), range(100i64, 300i64))
}
def exceptions(realized: List[f32], forecasts: List[f32]) -> i64 = fold(fn (acc: i64, p: (f32, f32)) -> if gt(p.0, p.1) then add(acc, 1i64) else acc, 0i64, zip(realized, forecasts))
-- likelihood-ratio statistics; at 95% they reject above their chi-square critical value
-- (Kupiec, 1 dof: 3.841; Christoffersen conditional coverage, 2 dof: 5.991, which also reports the verdict)
def kupiec(count: i64, days: i64) -> f32 = kupiec_pof_statistic_simple(count, days, 0.05f32)
def christoffersen(realized: List[f32], forecasts: List[f32]) -> (f32, bool) = re_christoffersen_cc(to_tensor(realized), to_tensor(forecasts), 0.05f32)
