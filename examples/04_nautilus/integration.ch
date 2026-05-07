module Hello.Nautilus.Integration

import Std.Tensor.Construct (to_tensor)
import Std.Tensor.Reduce (sum)
import Nautilus.Integrate (trapezoid, simpson, gauss_legendre, adaptive_simpson)
import Std.Test (assert_close)

// Integrate sin(x) from 0 to pi: exact value is 2.

def f(x: tensor[f32]) -> tensor[f32] = sin(x)

def test_trapezoid() -> unit ! { Test } = {
  r = trapezoid(f, cast(0.0, f32), cast(3.141592653, f32), cast(1000, int64))
  assert_close(r, 2.0, 1e-3, "trap_sin_pi")
}

def test_simpson() -> unit ! { Test } = {
  r = simpson(f, cast(0.0, f32), cast(3.141592653, f32), cast(1000, int64))
  assert_close(r, 2.0, 1e-5, "simpson_sin_pi")
}

def test_gauss_legendre() -> unit ! { Test } = {
  r = gauss_legendre(f, cast(0.0, f32), cast(3.141592653, f32), cast(8, int64))
  assert_close(r, 2.0, 1e-5, "gl_sin_pi")
}

def test_adaptive_simpson() -> unit ! { Test } = {
  r = adaptive_simpson(f, cast(0.0, f32), cast(3.141592653, f32), cast(1e-6, f32), cast(20, int64))
  assert_close(r, 2.0, 1e-5, "adaptive_sin_pi")
}
