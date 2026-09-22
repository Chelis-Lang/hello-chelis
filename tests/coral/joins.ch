module Hello.Tests.Coral.Joins
import Hello.Coral.Joins (inner, left, outer)
import Coral.Frame (nrows, ncols)
import Std.Test (assert_eq_int)
def test_inner_join_intersection() -> unit ! { Test } = {
  r = inner()
  _ = assert_eq_int(nrows(r), cast(2, i64), "inner join keeps 2 matching rows")
  assert_eq_int(ncols(r), cast(3, i64), "inner join: customer + qty + score == 3")
}
def test_left_join_keeps_left_side() -> unit ! { Test } = {
  r = left()
  _ = assert_eq_int(nrows(r), cast(3, i64), "left join keeps all 3 left rows")
  assert_eq_int(ncols(r), cast(3, i64), "left join: customer + qty + score == 3")
}
def test_outer_join_union() -> unit ! { Test } = {
  r = outer()
  _ = assert_eq_int(nrows(r), cast(4, i64), "outer join produces union of 4 rows")
  assert_eq_int(ncols(r), cast(3, i64), "outer join: customer + qty + score == 3")
}
