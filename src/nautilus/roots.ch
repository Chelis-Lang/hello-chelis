module Hello.Nautilus.Roots
import Nautilus.Roots (bisection, newton, brent)
export (sqrt2_bisect, sqrt2_brent, sqrt2_newton)
def quad_minus_2(x: f32) -> f32 = sub(mul(x, x), 2.0f32)
def dquad_minus_2(x: f32) -> f32 = mul(2.0f32, x)
def sqrt2_bisect() -> f32 = bisection(quad_minus_2, 1.0f32, 2.0f32, 1e-8f32, 100i64)
def sqrt2_brent() -> f32 = brent(quad_minus_2, 1.0f32, 2.0f32, 1e-10f32, 100i64)
def sqrt2_newton() -> f32 = newton(quad_minus_2, dquad_minus_2, 1.5f32, 1e-10f32, 50i64)
