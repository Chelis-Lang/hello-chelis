module Hello.Tests.Coral.Io

import Hello.Coral.Io (roundtrip_csv)
import Coral.Frame (nrows, ncols, get_float_col, get_string_col)
import Std.Test (assert_eq_int, assert_eq_string, assert_close)

def zero_i64() -> int64 = cast(0, int64)
def one_i64() -> int64 = cast(1, int64)

def test_csv_roundtrip_shape_and_values() -> unit ! { Test, IO } = {
  back = roundtrip_csv("/tmp/hello-coral.csv")
  prices = to_list(get_float_col(back, "price"))
  cities = get_string_col(back, "city")
  _ = assert_eq_int(nrows(back), cast(2, int64), "csv roundtrip nrows == 2");
  _ = assert_eq_int(ncols(back), cast(2, int64), "csv roundtrip ncols == 2");
  _ = assert_close(index(prices, zero_i64()), cast(10.5, f32), cast(1e-3, f32), "price[0] == 10.5");
  _ = assert_eq_string(index(cities, zero_i64()), "paris", "city[0] == paris");
  assert_eq_string(index(cities, one_i64()), "london", "city[1] == london")
}
