module Hello.Capstone.MlPipeline

import Coral.Frame (Frame, from_pairs, get_float_col, nrows)
import Coral.GroupBy (group_by, agg_mean)
import Nautilus.Stats (mean_vec, std_vec)

export (build_frame, mean_grouped, summary_stat)

-- A small end-to-end pipeline that touches three shells:
--   1. Coral builds a typed Frame from raw tensors
--   2. Std primitives (sum, mean) flow through tensor columns
--   3. Nautilus computes summary statistics on a numeric column

def build_frame(prices: tensor[n, f32], cities: List[string]) -> Frame =
  from_pairs([
    ("price", FloatCol(prices)),
    ("city",  StringCol(cities))
  ])

-- group_by(city) + agg_mean(price) returns a frame whose row count is the
-- number of unique cities.
def mean_grouped(prices: tensor[n, f32], cities: List[string]) -> int64 = {
  df = build_frame(prices, cities)
  totals = agg_mean(group_by(df, "city"), "price")
  nrows(totals)
}

-- Pull the numeric column back out and compute the population mean +
-- sample std via Nautilus.
def summary_stat(prices: tensor[n, f32], cities: List[string]) -> f32 = {
  df = build_frame(prices, cities)
  col = get_float_col(df, "price")
  add(mean_vec(copy(col)), std_vec(col, cast(1, int64)))
}
