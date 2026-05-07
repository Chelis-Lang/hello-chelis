module Hello.Tests.Nautilus.CurveFit

import Hello.Nautilus.CurveFit (fit_exp_decay, fit_linear_through_origin)
import Std.Test (assert_close)

def test_fit_exp_decay_recovers_half() -> unit ! { Test } =
  assert_close(fit_exp_decay(), cast(0.5, f32), cast(1.0e-3, f32),
               "y = exp(-theta*x) recovers theta = 0.5")

def test_fit_linear_recovers_two() -> unit ! { Test } =
  assert_close(fit_linear_through_origin(), cast(2.0, f32), cast(1.0e-4, f32),
               "y = theta*x recovers theta = 2")
