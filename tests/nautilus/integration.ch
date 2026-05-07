module Hello.Tests.Nautilus.Integration

import Hello.Nautilus.Integration (sin_integral_trap, sin_integral_simpson, sin_integral_gl5)
import Std.Test (assert_close)

def test_sin_integral_trap() -> unit ! { Test } =
  -- Trapezoidal converges as O(h^2); 1000 steps on smooth integrand is plenty.
  assert_close(sin_integral_trap(), cast(2.0, f32), cast(1.0e-3, f32), "trap int sin = 2")

def test_sin_integral_simpson() -> unit ! { Test } =
  assert_close(sin_integral_simpson(), cast(2.0, f32), cast(1.0e-5, f32), "simpson int sin = 2")

def test_sin_integral_gl5() -> unit ! { Test } =
  -- Gauss-Legendre exact for polynomials up to degree 9; sin truncation error is small.
  assert_close(sin_integral_gl5(), cast(2.0, f32), cast(1.0e-3, f32), "gl5 int sin ~ 2")
