module Hello.Tests.Nautilus.Integration
import Hello.Nautilus.Integration (sin_integral_trap, sin_integral_simpson, sin_integral_gl5)
import Std.Test (assert_close)
def test_sin_integral_trap() -> unit ! { Test } = assert_close(sin_integral_trap(), 2.0f32, 0.001f32, "trap int sin = 2")
def test_sin_integral_simpson() -> unit ! { Test } = assert_close(sin_integral_simpson(), 2.0f32, 0.00001f32, "simpson int sin = 2")
def test_sin_integral_gl5() -> unit ! { Test } = assert_close(sin_integral_gl5(), 2.0f32, 0.001f32, "gl5 int sin ~ 2")
