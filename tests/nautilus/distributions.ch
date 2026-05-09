module Hello.Tests.Nautilus.Distributions
import Hello.Nautilus.Distributions (std_normal_pdf, std_normal_cdf, std_normal_quantile, exp_cdf_half_life)
import Std.Test (assert_close)
def test_std_normal_pdf_at_zero() -> unit ! { Test } = assert_close(std_normal_pdf(cast(0.0, f32)), cast(0.3989423, f32), cast(0.00001, f32), "std_normal_pdf(0) = 1/sqrt(2pi)")
def test_std_normal_cdf_at_zero() -> unit ! { Test } = assert_close(std_normal_cdf(cast(0.0, f32)), cast(0.5, f32), cast(0.00001, f32), "Phi(0) = 0.5")
def test_std_normal_quantile_half() -> unit ! { Test } = assert_close(std_normal_quantile(cast(0.5, f32)), cast(0.0, f32), cast(0.00001, f32), "Phi^-1(0.5) = 0")
def test_exp_cdf_half_life() -> unit ! { Test } = assert_close(exp_cdf_half_life(), cast(0.5, f32), cast(0.00001, f32), "exponential cdf at ln 2 = 0.5")
