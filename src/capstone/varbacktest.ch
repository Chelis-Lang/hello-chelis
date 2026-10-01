module Hello.Capstone.VarBacktest
import Shoals.Risk (historical_var, historical_cvar, parametric_var, parametric_cvar)
import Shoals.RiskExt (kupiec_pof_statistic_simple, re_christoffersen_cc)
import Coral.Window (ewm)
import Nautilus.Distributions (normal_inv_cdf)
export (daily_return, sample_returns, to_losses, rolling_forecasts, adaptive_forecasts, exceptions, tail_risk, kupiec, christoffersen)
def shock(t: i64) -> f32 = {
  x = mul(cast(add(t, cast(1, i64)), f32), cast(0.618034, f32))
  normal_inv_cdf(sub(x, cast(cast_trunc(x, i64), f32)), cast(0.0, f32), cast(1.0, f32))
}
def daily_return(t: i64) -> f32 = mul(if lt(t, cast(150, i64)) then cast(0.01, f32) else cast(0.02, f32), shock(t))
def sample_returns() -> List[f32] = map(daily_return, range(cast(0, i64), cast(300, i64)))
def to_losses(rets: List[f32]) -> List[f32] = map(fn (r: f32) -> neg(r), rets)
def tail_risk(losses: List[f32]) -> (f32, f32, f32, f32) = (historical_var(to_tensor(losses), cast(0.95, f32)), historical_cvar(to_tensor(losses), cast(0.95, f32)), parametric_var(to_tensor(losses), cast(0.95, f32)), parametric_cvar(to_tensor(losses), cast(0.95, f32)))
def rolling_forecasts(losses: List[f32]) -> List[f32] = map(fn (t: i64) -> historical_var(to_tensor(take(skip(losses, sub(t, cast(100, i64))), cast(100, i64))), cast(0.95, f32)), range(cast(100, i64), cast(300, i64)))
def adaptive_forecasts(rets: List[f32]) -> List[f32] = {
  v = to_list(ewm(to_tensor(map(fn (r: f32) -> mul(r, r), rets)), cast(0.06, f32)))
  map(fn (t: i64) -> mul(cast(1.644854, f32), sqrt(index(v, sub(t, cast(1, i64))))), range(cast(100, i64), cast(300, i64)))
}
def exceptions(realized: List[f32], forecasts: List[f32]) -> i64 = fold(fn (acc: i64, p: (f32, f32)) -> if gt(p.0, p.1) then add(acc, cast(1, i64)) else acc, cast(0, i64), zip(realized, forecasts))
def kupiec(count: i64, days: i64) -> f32 = kupiec_pof_statistic_simple(count, days, cast(0.05, f32))
def christoffersen(realized: List[f32], forecasts: List[f32]) -> (f32, bool) = re_christoffersen_cc(to_tensor(realized), to_tensor(forecasts), cast(0.05, f32))
