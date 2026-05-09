module Hello.Tests.Nautilus.SpecialFunctions
import Hello.Nautilus.SpecialFunctions (erf_pipe, erf_round_trip, log_gamma_one, complementary_erf, j0_at_zero)
import Std.Test (assert_close)
def test_erf_pipe_zero() -> unit ! { Test } = assert_close(erf_pipe(cast(0.0, f32)), cast(0.0, f32), cast(0.000001, f32), "erf(0) = 0")
def test_erf_round_trip() -> unit ! { Test } = assert_close(erf_round_trip(cast(0.3, f32)), cast(0.3, f32), cast(0.00001, f32), "erf(erfinv(0.3)) = 0.3")
def test_log_gamma_one() -> unit ! { Test } = assert_close(log_gamma_one(), cast(0.0, f32), cast(0.000001, f32), "log_gamma(1) = 0")
def test_complementary_erf() -> unit ! { Test } = assert_close(complementary_erf(cast(0.7, f32)), cast(1.0, f32), cast(0.000001, f32), "erf + erfc = 1")
def test_bessel_j0_zero() -> unit ! { Test } = assert_close(j0_at_zero(), cast(1.0, f32), cast(0.000001, f32), "j0(0) = 1")
