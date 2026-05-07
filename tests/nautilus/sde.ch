module Hello.Tests.Nautilus.Sde

import Hello.Nautilus.Sde (gbm_path_zero_noise, em_one_step_decay)
import Std.Test (assert_close, assert_true)

def test_em_one_step_decay() -> unit ! { Test } =
  -- y_next = 1 + (-1)*0.1 + 0 = 0.9
  assert_close(em_one_step_decay(), cast(0.9, f32), cast(1.0e-6, f32),
               "EM step decay y0=1 dt=0.1 -> 0.9")

def test_gbm_zero_noise_close_to_exp() -> unit ! { Test } = {
  -- With zero noise EM becomes forward Euler on dy/dt = 0.1*y.
  -- 10 Euler steps with dt=0.1 give (1.01)^10 ~ 1.10462.
  y = gbm_path_zero_noise()
  -- Loose tolerance: forward Euler is O(h).
  assert_close(y, cast(1.10462, f32), cast(1.0e-3, f32),
               "GBM zero-noise approximates (1+mu*dt)^n")
}

def test_gbm_zero_noise_finite_positive() -> unit ! { Test } = {
  y = gbm_path_zero_noise()
  assert_true(gt(y, cast(1.0, f32)), "GBM zero-noise with positive drift > y0")
}
