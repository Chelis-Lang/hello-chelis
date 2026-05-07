module Hello.Nautilus.SpecialFunctions

import Nautilus.Special (erf, erfc, erfinv, log_gamma, bessel_j0)

export (erf_pipe, erf_round_trip, log_gamma_one, complementary_erf, j0_at_zero)

-- Pipe a scalar through erf.
def erf_pipe(x: f32) -> f32 =
  x |> erf

-- erf(erfinv(y)) round-trip should recover y.
def erf_round_trip(y: f32) -> f32 =
  y |> erfinv |> erf

-- log_gamma(1) = 0 since gamma(1) = 1.
def log_gamma_one() -> f32 =
  log_gamma(cast(1.0, f32))

-- erf(x) + erfc(x) = 1.
def complementary_erf(x: f32) -> f32 =
  add(erf(x), erfc(x))

-- bessel_j0(0) = 1.
def j0_at_zero() -> f32 =
  bessel_j0(cast(0.0, f32))
