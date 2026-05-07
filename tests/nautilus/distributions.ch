module Hello.Tests.Nautilus.Distributions

import Hello.Nautilus.Distributions (std_normal_pdf, std_normal_cdf, std_normal_quantile, exp_cdf_half_life)
import Std.Test (assert_close)

def test_std_normal_pdf_at_zero() -> unit ! { Test } =
  -- N(0;0,1) = 1/sqrt(2*pi) ~ 0.3989422804
  assert_close(std_normal_pdf(cast(0.0, f32)), cast(0.3989423, f32), cast(1.0e-5, f32),
               "std_normal_pdf(0) = 1/sqrt(2pi)")

def test_std_normal_cdf_at_zero() -> unit ! { Test } =
  assert_close(std_normal_cdf(cast(0.0, f32)), cast(0.5, f32), cast(1.0e-5, f32),
               "Phi(0) = 0.5")

def test_std_normal_quantile_half() -> unit ! { Test } =
  -- inverse CDF at 0.5 is the median = 0.
  assert_close(std_normal_quantile(cast(0.5, f32)), cast(0.0, f32), cast(1.0e-5, f32),
               "Phi^-1(0.5) = 0")

def test_exp_cdf_half_life() -> unit ! { Test } =
  assert_close(exp_cdf_half_life(), cast(0.5, f32), cast(1.0e-5, f32),
               "exponential cdf at ln 2 = 0.5")
