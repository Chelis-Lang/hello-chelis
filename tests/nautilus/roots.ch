module Hello.Tests.Nautilus.Roots
import Hello.Nautilus.Roots (sqrt2_bisect, sqrt2_brent, sqrt2_newton)
import Std.Test (assert_close)
def test_sqrt2_bisect() -> unit ! { Test } = assert_close(sqrt2_bisect(), 1.4142135f32, 0.00001f32, "bisection sqrt(2)")
def test_sqrt2_brent() -> unit ! { Test } = assert_close(sqrt2_brent(), 1.4142135f32, 0.00001f32, "brent sqrt(2)")
def test_sqrt2_newton() -> unit ! { Test } = assert_close(sqrt2_newton(), 1.4142135f32, 0.00001f32, "newton sqrt(2)")
