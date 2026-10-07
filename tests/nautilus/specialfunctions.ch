module Hello.Tests.Nautilus.SpecialFunctions
import Hello.Nautilus.SpecialFunctions (erf_pipe, erf_round_trip, log_gamma_one, complementary_erf, j0_at_zero)
import Std.Test (assert_close, assert_true)
def test_erf_pipe_zero() -> unit ! { Test } = assert_close(erf_pipe(0.0f32), 0.0f32, 1e-6f32, "erf(0) = 0")
def test_erf_round_trip() -> unit ! { Test } = assert_close(erf_round_trip(0.3f32), 0.3f32, 0.00001f32, "erf(erfinv(0.3)) = 0.3")
def test_log_gamma_one() -> unit ! { Test } = assert_close(log_gamma_one(), 0.0f32, 1e-6f32, "log_gamma(1) = 0")
def test_complementary_erf() -> unit ! { Test } = assert_close(complementary_erf(0.7f32), 1.0f32, 1e-6f32, "erf + erfc = 1")
def test_builtin_erfc_tail() -> unit ! { Test } = assert_true(gt(erfc(4.0f32), 0.0f32), "Chelis erfc retains the positive f32 tail")
def test_bessel_j0_zero() -> unit ! { Test } = assert_close(j0_at_zero(), 1.0f32, 1e-6f32, "j0(0) = 1")
