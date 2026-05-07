module Hello.Nautilus.Integration

import Nautilus.Integrate (trapezoidal, simpsons, gauss_legendre_5)

export (sin_integral_trap, sin_integral_simpson, sin_integral_gl5)

-- Sin from 0 to pi has integral 2.
def sin_fn(x: f32) -> f32 = sin(x)

def pi_f() -> f32 = cast(3.1415927, f32)

-- Trapezoidal rule on sin from 0 to pi.
def sin_integral_trap() -> f32 =
  trapezoidal(sin_fn, cast(0.0, f32), pi_f(), cast(1000, int64))

-- Simpson's rule on sin from 0 to pi.
def sin_integral_simpson() -> f32 =
  simpsons(sin_fn, cast(0.0, f32), pi_f(), cast(100, int64))

-- 5-point Gauss-Legendre on sin from 0 to pi (n_points argument is ignored
-- by the fixed-rule but required by the API).
def sin_integral_gl5() -> f32 =
  gauss_legendre_5(sin_fn, cast(0.0, f32), pi_f(), cast(5, int64))
