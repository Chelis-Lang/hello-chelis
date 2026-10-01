module Hello.Nautilus.Integration
import Nautilus.Integrate (trapezoidal, simpsons, gauss_legendre_5)
export (sin_integral_trap, sin_integral_simpson, sin_integral_gl5)
def sin_fn(x: f32) -> f32 = sin(x)
def pi_f() -> f32 = 3.1415927f32
def sin_integral_trap() -> f32 = trapezoidal(sin_fn, 0.0f32, pi_f(), 100i64)
def sin_integral_simpson() -> f32 = simpsons(sin_fn, 0.0f32, pi_f(), 100i64)
def sin_integral_gl5() -> f32 = gauss_legendre_5(sin_fn, 0.0f32, pi_f(), 5i64)
