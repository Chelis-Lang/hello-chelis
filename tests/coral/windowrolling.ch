module Hello.Tests.Coral.WindowRolling
import Hello.Coral.WindowRolling (mean3, std3, ewm_half)
import Std.Test (assert_close, assert_true)
def is_nan_local(x: f32) -> bool = neq(x, x)
def test_rolling_mean_window_3() -> unit ! { Test } = {
  out = to_list(mean3())
  _ = assert_true(is_nan_local(index(out, cast(0, i64))), "mean3[0] is NaN")
  _ = assert_close(index(out, cast(2, i64)), cast(2.0, f32), cast(0.00001, f32), "mean3[2] == 2.0")
  _ = assert_close(index(out, cast(3, i64)), cast(3.0, f32), cast(0.00001, f32), "mean3[3] == 3.0")
  assert_close(index(out, cast(4, i64)), cast(4.0, f32), cast(0.00001, f32), "mean3[4] == 4.0")
}
def test_rolling_std_window_3() -> unit ! { Test } = {
  out = to_list(std3())
  assert_close(index(out, cast(2, i64)), cast(1.0, f32), cast(0.0001, f32), "std3[2] == 1.0")
}
def test_ewm_alpha_half() -> unit ! { Test } = {
  out = to_list(ewm_half())
  _ = assert_close(index(out, cast(0, i64)), cast(1.0, f32), cast(0.00001, f32), "ewm[0] == 1.0")
  assert_close(index(out, cast(1, i64)), cast(1.5, f32), cast(0.00001, f32), "ewm[1] == 1.5")
}
