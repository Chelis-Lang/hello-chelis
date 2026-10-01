module Hello.Tests.Nautilus.Optimize
import Hello.Nautilus.Optimize (parabola_minimum_gss, parabola_minimum_brent, parabola_minimum_newton)
import Std.Test (assert_close)
def test_parabola_minimum_gss() -> unit ! { Test } = assert_close(parabola_minimum_gss(), 3.0f32, 0.0005f32, "golden-section min of (x-3)^2 + 7")
def test_parabola_minimum_brent() -> unit ! { Test } = assert_close(parabola_minimum_brent(), 3.0f32, 0.0005f32, "brent min of (x-3)^2 + 7")
def test_parabola_minimum_newton() -> unit ! { Test } = assert_close(parabola_minimum_newton(), 3.0f32, 0.00001f32, "newton 1D min of (x-3)^2 + 7")
