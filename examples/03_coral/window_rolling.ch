module Hello.Coral.WindowRolling

import Std.Tensor.Construct (to_tensor)
import Coral.Window (rolling_mean, rolling_std, ewm)
import Std.Test (assert_close)

// Window functions operate directly on tensor-backed columns. They produce
// a new tensor with NaNs for the first `window-1` positions.

def smoothed_value() -> f32 = {
  values = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32), cast(4.0, f32), cast(5.0, f32)])
  window = cast(3, int64)
  m = rolling_mean(copy(values), window)
  // mean over the last 3 of [3,4,5] = 4.0
  index(to_list(m), cast(4, int64))
}

def smoothed_std() -> f32 = {
  values = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32), cast(4.0, f32), cast(5.0, f32)])
  s = rolling_std(values, cast(3, int64))
  // sample std (ddof=1) of [3,4,5] = 1.0
  index(to_list(s), cast(4, int64))
}

def ewm_value() -> f32 = {
  values = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32), cast(4.0, f32), cast(5.0, f32)])
  e = ewm(values, cast(0.5, f32))
  index(to_list(e), cast(4, int64))
}

def test_rolling_mean() -> unit ! { Test } = {
  assert_close(smoothed_value(), 4.0, 1e-6, "roll_mean_5")
}

def test_rolling_std() -> unit ! { Test } = {
  assert_close(smoothed_std(), 1.0, 1e-6, "roll_std_5")
}

def test_ewm() -> unit ! { Test } = {
  // For alpha=0.5 over [1,2,3,4,5], the recursive EWM converges close
  // to the input. Non-zero, finite, less than 5.0.
  v = ewm_value()
  assert_close(v, 4.0, 0.6, "ewm_5_approx")
}
