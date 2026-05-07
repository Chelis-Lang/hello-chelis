module Hello.Coral.GroupbyAgg

import Std.Tensor.Construct (to_tensor)
import Coral.Frame (Frame, from_pairs, nrows, int_col_of_list)
import Coral.GroupBy (group_by, agg_sum, agg_mean, value_counts)
import Std.Test (assert_eq_int)

def trades() -> Frame = {
  from_pairs([
    ("city", StringCol(["london", "paris", "london", "paris", "london"])),
    ("qty",  int_col_of_list([cast(5, int64), cast(7, int64), cast(11, int64), cast(13, int64), cast(17, int64)])),
    ("price", FloatCol(to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32), cast(4.0, f32), cast(5.0, f32)])))
  ])
}

def by_city_sum() -> Frame =
  agg_sum(group_by(trades(), "city"), "qty")

def by_city_mean() -> Frame =
  agg_mean(group_by(trades(), "city"), "price")

def city_counts() -> Frame =
  value_counts(trades(), "city")

def test_groupby_yields_two_cities() -> unit ! { Test } = {
  // London + Paris -> 2 unique groups -> 2 rows
  assert_eq_int(nrows(by_city_sum()), cast(2, int64), "groupby_2_cities")
}

def test_value_counts() -> unit ! { Test } = {
  assert_eq_int(nrows(city_counts()), cast(2, int64), "value_counts_2")
}

def test_groupby_mean_yields_two() -> unit ! { Test } = {
  assert_eq_int(nrows(by_city_mean()), cast(2, int64), "groupby_mean_2")
}
