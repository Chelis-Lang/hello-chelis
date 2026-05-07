module Hello.Coral.ReshapePivot

import Std.Tensor.Construct (to_tensor)
import Coral.Frame (Frame, from_pairs, nrows, ncols)
import Coral.Reshape (pivot, melt)
import Std.Test (assert_eq_int)

def long_form() -> Frame = {
  from_pairs([
    ("city", StringCol(["london", "paris", "london", "paris"])),
    ("year", StringCol(["2025", "2025", "2026", "2026"])),
    ("price", FloatCol(to_tensor([cast(10.0, f32), cast(20.0, f32), cast(15.0, f32), cast(25.0, f32)])))
  ])
}

// pivot: long -> wide. One row per (city), one column per (year).
def wide_form() -> Frame =
  pivot(long_form(), "city", "year", "price")

def test_pivot() -> unit ! { Test } = {
  w = wide_form()
  // 2 unique cities -> 2 rows; city + 2 years => 3 columns
  assert_eq_int(nrows(w), cast(2, int64), "pivot_rows")
  assert_eq_int(ncols(w), cast(3, int64), "pivot_cols")
}

def test_melt_inverse() -> unit ! { Test } = {
  // Melt is the inverse: wide -> long. Column-major: every value for
  // value_col[0] before value_col[1].
  out = melt(wide_form(), ["city"], ["2025", "2026"])
  assert_eq_int(nrows(out), cast(4, int64), "melt_rows")
}
