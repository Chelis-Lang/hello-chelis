module Hello.Tests.Coral.Reshape
import Hello.Coral.Reshape (pivoted, melted)
import Coral.Frame (nrows, ncols)
import Std.Test (assert_eq)
def test_pivot_shape() -> unit ! { Test } = {
  p = pivoted()
  _ = assert_eq(nrows(p), 2i64, "pivot: 2 distinct cities")
  assert_eq(ncols(p), 3i64, "pivot: city + x + y == 3 cols")
}
def test_melt_shape() -> unit ! { Test } = {
  m = melted()
  _ = assert_eq(nrows(m), 6i64, "melt: 3 rows * 2 value cols == 6")
  assert_eq(ncols(m), 3i64, "melt: city + variable + value == 3 cols")
}
