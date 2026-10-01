module Hello.Tests.Coral.WindowRolling
import Hello.Coral.WindowRolling (mean3, std3, ewm_half)
import Std.Test (assert_close, assert_true)
def is_nan_local(x: f32) -> bool = neq(x, x)
def test_rolling_mean_window_3() -> unit ! { Test } = {
  out = to_list(mean3())
  _ = assert_true(is_nan_local(index(out, 0i64)), "mean3[0] is NaN")
  _ = assert_close(index(out, 2i64), 2.0f32, 0.00001f32, "mean3[2] == 2.0")
  _ = assert_close(index(out, 3i64), 3.0f32, 0.00001f32, "mean3[3] == 3.0")
  assert_close(index(out, 4i64), 4.0f32, 0.00001f32, "mean3[4] == 4.0")
}
def test_rolling_std_window_3() -> unit ! { Test } = {
  out = to_list(std3())
  assert_close(index(out, 2i64), 1.0f32, 0.0001f32, "std3[2] == 1.0")
}
def test_ewm_alpha_half() -> unit ! { Test } = {
  out = to_list(ewm_half())
  _ = assert_close(index(out, 0i64), 1.0f32, 0.00001f32, "ewm[0] == 1.0")
  assert_close(index(out, 1i64), 1.5f32, 0.00001f32, "ewm[1] == 1.5")
}
