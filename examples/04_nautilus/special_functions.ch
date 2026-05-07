module Hello.Nautilus.SpecialFunctions

import Nautilus.Special (erf, gamma, log_gamma, j0, ai)
import Std.Test (assert_close)

def test_erf_zero() -> unit ! { Test } =
  assert_close(erf(cast(0.0, f32)), 0.0, 1e-6, "erf_0")

def test_erf_inf_approaches_one() -> unit ! { Test } =
  assert_close(erf(cast(3.0, f32)), 0.99998, 1e-3, "erf_3")

def test_gamma_5_eq_24() -> unit ! { Test } =
  // gamma(5) = 4! = 24
  assert_close(gamma(cast(5.0, f32)), 24.0, 1e-3, "gamma_5")

def test_log_gamma_1_eq_0() -> unit ! { Test } =
  assert_close(log_gamma(cast(1.0, f32)), 0.0, 1e-6, "log_gamma_1")

def test_j0_at_zero_is_one() -> unit ! { Test } =
  assert_close(j0(cast(0.0, f32)), 1.0, 1e-6, "j0_0")

def test_airy_at_zero() -> unit ! { Test } =
  // Ai(0) = 1 / (3^(2/3) * Gamma(2/3)) ~= 0.355
  assert_close(ai(cast(0.0, f32)), 0.355, 1e-2, "ai_0")
