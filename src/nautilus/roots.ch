module Hello.Nautilus.Roots

import Nautilus.Roots (bisection, newton, brent)

export (sqrt2_bisect, sqrt2_brent, sqrt2_newton)

-- f(x) = x*x - 2. Zero at sqrt(2).
def quad_minus_2(x: f32) -> f32 = sub(mul(x, x), cast(2.0, f32))

-- f'(x) = 2x.
def dquad_minus_2(x: f32) -> f32 = mul(cast(2.0, f32), x)

-- sqrt(2) via bisection on [1, 2].
def sqrt2_bisect() -> f32 =
  bisection(quad_minus_2, cast(1.0, f32), cast(2.0, f32),
            cast(1.0e-8, f32), cast(100, int64))

-- sqrt(2) via Brent's method on [1, 2].
def sqrt2_brent() -> f32 =
  brent(quad_minus_2, cast(1.0, f32), cast(2.0, f32),
        cast(1.0e-10, f32), cast(100, int64))

-- sqrt(2) via Newton's method from initial guess 1.5.
def sqrt2_newton() -> f32 =
  newton(quad_minus_2, dquad_minus_2, cast(1.5, f32),
         cast(1.0e-10, f32), cast(50, int64))
