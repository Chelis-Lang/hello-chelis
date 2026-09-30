module Hello.Capstone.ReturnsRisk
import Coral.Frame (Frame, FloatCol, StringCol, from_pairs, get_float_col, nrows)
import Coral.GroupBy (group_by, agg_mean)
import Coral.Window (rolling_std)
import Nautilus.Stats (mean_vec, std_vec)
import Nautilus.Distributions (normal_inv_cdf)
export (simple_returns, returns_frame, tickers_covered, sharpe_ratio, portfolio_sharpe, rolling_volatility, parametric_var)
def simple_returns(prices: List[f32]) -> List[f32] = {
  steps = sub(len(prices), cast(1, i64))
  pairs = zip(take(prices, steps), skip(prices, cast(1, i64)))
  map(fn (pair: (f32, f32)) -> div(sub(pair.1, pair.0), pair.0), pairs)
}
def returns_frame[n](tickers: List[string], rets: tensor[n, f32]) -> Frame[n] = from_pairs([("ticker", StringCol(tickers)), ("ret", FloatCol(rets))])
def tickers_covered[n](tickers: List[string], rets: tensor[n, f32]) -> i64 = nrows(agg_mean(group_by(returns_frame(tickers, rets), "ticker"), "ret"))
def sharpe_ratio[n](rets: &tensor[n, f32], risk_free: f32) -> f32 = div(sub(mean_vec(rets), risk_free), std_vec(rets, cast(1, i64)))
def portfolio_sharpe[n](tickers: List[string], rets: tensor[n, f32], risk_free: f32) -> f32 = {
  df = returns_frame(tickers, rets)
  sharpe_ratio(get_float_col(df, "ret"), risk_free)
}
def rolling_volatility[n](rets: tensor[n, f32], window: i64) -> tensor[n, f32] = rolling_std(rets, window)
def parametric_var[n](rets: &tensor[n, f32], confidence: f32) -> f32 = {
  z = normal_inv_cdf(sub(cast(1.0, f32), confidence), cast(0.0, f32), cast(1.0, f32))
  neg(add(mean_vec(rets), mul(z, std_vec(rets, cast(1, i64)))))
}
