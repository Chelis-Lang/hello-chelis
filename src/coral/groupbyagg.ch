module Hello.Coral.GroupByAgg

import Coral.Frame (Frame, Column, from_pairs, nrows, ncols, get_float_col)
import Coral.GroupBy (group_by, agg_sum, agg_mean)

export (sales_frame, total_per_city, mean_per_city)

-- A small "sales" frame: 4 rows, 2 cities, with a numeric quantity column.
def sales_frame() -> Frame[4] = {
  from_pairs([
    ("city", StringCol(["a", "b", "a", "b"])),
    ("qty", FloatCol(to_tensor([cast(1.0, f32), cast(10.0, f32), cast(2.0, f32), cast(20.0, f32)])))
  ])
}

-- group_by(city) + agg_sum(qty) -> 2-row frame whose qty_sum equals the per-city totals.
def total_per_city() -> Frame[2] = {
  sales_frame()
  |> group_by("city")
  |> agg_sum("qty")
}

-- group_by(city) + agg_mean(qty) -> 2-row frame; means are 1.5 (a) and 15 (b).
def mean_per_city() -> Frame[2] = {
  sales_frame()
  |> group_by("city")
  |> agg_mean("qty")
}
