module Hello.Tests.Capstone.MlPipeline
import Hello.Capstone.MlPipeline (mean_grouped, summary_stat)
import Std.Test (assert_eq_int, assert_close)
def test_grouped_two_cities() -> unit ! { Test } = {
  prices = to_tensor([cast(10.0, f32), cast(20.0, f32), cast(15.0, f32), cast(25.0, f32)])
  cities = ["london", "paris", "london", "paris"]
  assert_eq_int(mean_grouped(prices, cities), cast(2, i64), "groupby_two_cities")
}
def test_summary_stat() -> unit ! { Test } = {
  prices = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32), cast(4.0, f32), cast(5.0, f32)])
  cities = ["a", "b", "c", "d", "e"]
  assert_close(summary_stat(prices, cities), cast(4.5811, f32), cast(0.01, f32), "mean_plus_std")
}
