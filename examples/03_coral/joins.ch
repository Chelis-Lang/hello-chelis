module Hello.Coral.Joins

import Std.Tensor.Construct (to_tensor)
import Coral.Frame (Frame, from_pairs, nrows, int_col_of_list)
import Coral.Join (inner_join, left_join, outer_join)
import Std.Test (assert_eq_int)

def customers() -> Frame = {
  from_pairs([
    ("id",   int_col_of_list([cast(1, int64), cast(2, int64), cast(3, int64)])),
    ("name", StringCol(["alpha", "beta", "gamma"]))
  ])
}

def orders() -> Frame = {
  from_pairs([
    ("id",  int_col_of_list([cast(1, int64), cast(1, int64), cast(2, int64), cast(4, int64)])),
    ("amt", FloatCol(to_tensor([cast(10.0, f32), cast(20.0, f32), cast(30.0, f32), cast(40.0, f32)])))
  ])
}

def test_inner_join() -> unit ! { Test } = {
  // ids 1,1,2 match (id=4 has no customer; id=3 has no order) -> 3 rows
  out = inner_join(customers(), orders(), "id")
  assert_eq_int(nrows(out), cast(3, int64), "inner_3")
}

def test_left_join() -> unit ! { Test } = {
  // every customer kept (3); orphan order id=4 dropped -> 4 rows total
  // (alpha x 2 orders + beta x 1 + gamma x 1-with-NaN)
  out = left_join(customers(), orders(), "id")
  assert_eq_int(nrows(out), cast(4, int64), "left_4")
}

def test_outer_join() -> unit ! { Test } = {
  // 3 customer rows + 4 order rows but joined => 5 unique (left-sequential
  // first, right-only appended)
  out = outer_join(customers(), orders(), "id")
  assert_eq_int(nrows(out), cast(5, int64), "outer_5")
}
