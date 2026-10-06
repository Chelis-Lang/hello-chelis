module Hello.Nautilus.SpecialFunctions
import Nautilus.Special (erfinv, log_gamma, bessel_j0)
export (erf_pipe, erf_round_trip, log_gamma_one, complementary_erf, j0_at_zero)
def erf_pipe(x: f32) -> f32 = erf(x)
def erf_round_trip(y: f32) -> f32 = erf(erfinv(y))
def log_gamma_one() -> f32 = log_gamma(1.0f32)
def complementary_erf(x: f32) -> f32 = add(erf(x), erfc(x))
def j0_at_zero() -> f32 = bessel_j0(0.0f32)
