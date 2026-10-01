module Hello.Tests.Std.Reductions
import Hello.Std.Reductions (sum_axis0, prod_axis0, sum_rows)
import Std.Test (assert_close)
def sample_grid() -> tensor[2, 2, f32] = to_tensor([[cast(1.0, f32), cast(2.0, f32)], [cast(3.0, f32), cast(4.0, f32)]])
def test_sum_axis0() -> unit ! { Test } = {
  out = to_list(sum_axis0(sample_grid()))
  _ = assert_close(index(out, cast(0, i64)), cast(4.0, f32), cast(1e-6, f32), "column 0 sums to 4")
  assert_close(index(out, cast(1, i64)), cast(6.0, f32), cast(1e-6, f32), "column 1 sums to 6")
}
def test_prod_axis0() -> unit ! { Test } = {
  out = to_list(prod_axis0(sample_grid()))
  _ = assert_close(index(out, cast(0, i64)), cast(3.0, f32), cast(1e-6, f32), "column 0 product is 3")
  assert_close(index(out, cast(1, i64)), cast(8.0, f32), cast(1e-6, f32), "column 1 product is 8")
}
def test_sum_rows() -> unit ! { Test } = {
  out = to_list(sum_rows(sample_grid()))
  _ = assert_close(index(out, cast(0, i64)), cast(3.0, f32), cast(1e-6, f32), "row 0 sums to 3")
  assert_close(index(out, cast(1, i64)), cast(7.0, f32), cast(1e-6, f32), "row 1 sums to 7")
}
