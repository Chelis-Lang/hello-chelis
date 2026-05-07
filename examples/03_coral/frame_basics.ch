module Hello.Coral.FrameBasics

import Std.Tensor.Construct (to_tensor)
import Coral.Frame (
  Frame, from_pairs, nrows, ncols, columns,
  with_column, rename, drop_column, int_col_of_list
)
import Std.Test (assert_eq_int)

// Typed columns: FloatCol / IntCol / StringCol / BoolCol. Numeric columns
// are tensor-backed; string columns use host-path equality.

def build() -> Frame = {
  from_pairs([
    ("price", FloatCol(to_tensor([cast(10.0, f32), cast(20.0, f32), cast(30.0, f32)]))),
    ("qty",   int_col_of_list([cast(1, int64), cast(2, int64), cast(3, int64)])),
    ("name",  StringCol(["alpha", "beta", "gamma"]))
  ])
}

def mutated() -> Frame = {
  base = build()
  renamed = rename(base, "price", "cost")
  extended = with_column(renamed, "tax", int_col_of_list([cast(1, int64), cast(1, int64), cast(2, int64)]))
  drop_column(extended, "qty")
}

def test_shape() -> unit ! { Test } = {
  f = build()
  assert_eq_int(nrows(f), cast(3, int64), "build_nrows")
  assert_eq_int(ncols(f), cast(3, int64), "build_ncols")
}

def test_mutation() -> unit ! { Test } = {
  f = mutated()
  // dropped qty, kept cost, name; added tax => 3 columns
  assert_eq_int(ncols(f), cast(3, int64), "mutated_ncols")
}
