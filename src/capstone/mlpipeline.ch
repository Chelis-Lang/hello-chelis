module Hello.Capstone.MlPipeline
import Coral.Frame (Frame, FloatCol, StringCol, from_pairs, get_float_col, nrows)
import Coral.GroupBy (group_by, agg_mean)
import Nautilus.Stats (mean_vec, std_vec)
export (build_frame, mean_grouped, summary_stat)
def build_frame(prices: tensor[n, f32], cities: List[string]) -> Frame[n] = from_pairs([("price", FloatCol(prices)), ("city", StringCol(cities))])
def mean_grouped(prices: tensor[n, f32], cities: List[string]) -> int64 = {
  df = build_frame(prices, cities)
  totals = agg_mean(group_by(df, "city"), "price")
  nrows(totals)
}
def summary_stat(prices: tensor[n, f32], cities: List[string]) -> f32 = {
  df = build_frame(prices, cities)
  col = get_float_col(df, "price")
  add(mean_vec(col), std_vec(col, cast(1, int64)))
}
