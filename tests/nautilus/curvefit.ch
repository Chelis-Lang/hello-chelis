module Hello.Tests.Nautilus.CurveFit
import Hello.Nautilus.CurveFit (fit_exp_decay, fit_linear_through_origin)
import Std.Test (assert_close)
def test_fit_exp_decay_recovers_half() -> unit ! { Test } = assert_close(fit_exp_decay(), 0.5f32, 0.001f32, "y = exp(-theta*x) recovers theta = 0.5")
def test_fit_linear_recovers_two() -> unit ! { Test } = assert_close(fit_linear_through_origin(), 2.0f32, 0.0001f32, "y = theta*x recovers theta = 2")
