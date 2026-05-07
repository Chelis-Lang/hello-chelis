module Hello.Tests.Nautilus.Roots

import Hello.Nautilus.Roots (sqrt2_bisect, sqrt2_brent, sqrt2_newton)
import Std.Test (assert_close)

-- sqrt(2) ~ 1.4142135623730951

def test_sqrt2_bisect() -> unit ! { Test } =
  assert_close(sqrt2_bisect(), cast(1.4142135, f32), cast(1.0e-5, f32), "bisection sqrt(2)")

def test_sqrt2_brent() -> unit ! { Test } =
  assert_close(sqrt2_brent(), cast(1.4142135, f32), cast(1.0e-5, f32), "brent sqrt(2)")

def test_sqrt2_newton() -> unit ! { Test } =
  assert_close(sqrt2_newton(), cast(1.4142135, f32), cast(1.0e-5, f32), "newton sqrt(2)")
