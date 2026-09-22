module Hello.Tests.Coral.GroupByAgg
import Hello.Coral.GroupByAgg (sales_frame, total_per_city, mean_per_city)
import Coral.Frame (nrows, ncols, get_float_col)
import Std.Test (assert_eq_int, assert_close)
def zero_i64() -> i64 = cast(0, i64)
def tensor_sum_f32[n](t: tensor[n, f32]) -> f32 = fold(fn (acc: f32, v: f32) -> add(acc, v), cast(0.0, f32), to_list(t))
def test_sales_frame_shape() -> unit ! { Test } = {
  df = sales_frame()
  _ = assert_eq_int(nrows(df), cast(4, i64), "sales nrows == 4")
  assert_eq_int(ncols(df), cast(2, i64), "sales ncols == 2")
}
def test_agg_sum_per_city() -> unit ! { Test } = {
  result = total_per_city()
  total = tensor_sum_f32(get_float_col(result, "qty_sum"))
  _ = assert_eq_int(nrows(result), cast(2, i64), "two unique cities")
  _ = assert_eq_int(ncols(result), cast(2, i64), "key + qty_sum")
  assert_close(total, cast(33.0, f32), cast(0.001, f32), "sum of per-city totals == 33")
}
def test_agg_mean_per_city() -> unit ! { Test } = {
  result = mean_per_city()
  total = tensor_sum_f32(get_float_col(result, "qty_mean"))
  _ = assert_eq_int(nrows(result), cast(2, i64), "two unique cities")
  assert_close(total, cast(16.5, f32), cast(0.001, f32), "sum of per-city means == 16.5")
}
