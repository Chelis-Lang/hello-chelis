module Hello.Tests.Coral.Io
import Hello.Coral.Io (roundtrip_csv)
import Coral.Frame (nrows, ncols, get_float_col, get_string_col)
import Std.Test (assert_eq, assert_close)
def zero_i64() -> i64 = 0i64
def one_i64() -> i64 = 1i64
def test_csv_roundtrip_shape_and_values() -> unit ! { Test, IO } = {
  back = roundtrip_csv("/tmp/hello-coral.csv")
  prices = to_list(get_float_col(back, "price"))
  cities = get_string_col(back, "city")
  _ = assert_eq(nrows(back), 2i64, "csv roundtrip nrows == 2")
  _ = assert_eq(ncols(back), 2i64, "csv roundtrip ncols == 2")
  _ = assert_close(index(prices, zero_i64()), 10.5f32, 0.001f32, "price[0] == 10.5")
  _ = assert_eq(index(cities, zero_i64()), "paris", "city[0] == paris")
  assert_eq(index(cities, one_i64()), "london", "city[1] == london")
}
