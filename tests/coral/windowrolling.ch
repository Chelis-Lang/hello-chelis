module Hello.Tests.Coral.WindowRolling

import Hello.Coral.WindowRolling (mean3, std3, ewm_half)
import Std.Test (assert_close, assert_true)

def is_nan_local(x: f32) -> bool = neq(x, x)

def test_rolling_mean_window_3() -> unit ! { Test } = {
  out = to_list(mean3())
  -- First two values are NaN (window not yet full); 3..4 are 2.0, 3.0, 4.0.
  _ = assert_true(is_nan_local(index(out, cast(0, int64))), "mean3[0] is NaN");
  _ = assert_close(index(out, cast(2, int64)), cast(2.0, f32), cast(1e-5, f32), "mean3[2] == 2.0");
  _ = assert_close(index(out, cast(3, int64)), cast(3.0, f32), cast(1e-5, f32), "mean3[3] == 3.0");
  assert_close(index(out, cast(4, int64)), cast(4.0, f32), cast(1e-5, f32), "mean3[4] == 4.0")
}

def test_rolling_std_window_3() -> unit ! { Test } = {
  out = to_list(std3())
  -- std of [1,2,3] (sample, ddof=1) = 1.0
  assert_close(index(out, cast(2, int64)), cast(1.0, f32), cast(1e-4, f32), "std3[2] == 1.0")
}

def test_ewm_alpha_half() -> unit ! { Test } = {
  out = to_list(ewm_half())
  -- ewm with init=first and alpha=0.5:
  --   y[0] = 1
  --   y[1] = 0.5*2 + 0.5*1 = 1.5
  _ = assert_close(index(out, cast(0, int64)), cast(1.0, f32), cast(1e-5, f32), "ewm[0] == 1.0");
  assert_close(index(out, cast(1, int64)), cast(1.5, f32), cast(1e-5, f32), "ewm[1] == 1.5")
}
