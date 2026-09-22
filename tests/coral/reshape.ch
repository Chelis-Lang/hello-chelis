module Hello.Tests.Coral.Reshape
import Hello.Coral.Reshape (pivoted, melted)
import Coral.Frame (nrows, ncols)
import Std.Test (assert_eq_int)
def test_pivot_shape() -> unit ! { Test } = {
  p = pivoted()
  _ = assert_eq_int(nrows(p), cast(2, i64), "pivot: 2 distinct cities")
  assert_eq_int(ncols(p), cast(3, i64), "pivot: city + x + y == 3 cols")
}
def test_melt_shape() -> unit ! { Test } = {
  m = melted()
  _ = assert_eq_int(nrows(m), cast(6, i64), "melt: 3 rows * 2 value cols == 6")
  assert_eq_int(ncols(m), cast(3, i64), "melt: city + variable + value == 3 cols")
}
