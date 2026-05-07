module Hello.Nautilus.Distributions

import Nautilus.Distributions (normal_pdf, normal_cdf, normal_inv_cdf, exponential_cdf)

export (std_normal_pdf, std_normal_cdf, std_normal_quantile, exp_cdf_half_life)

-- Standard normal pdf at x: N(x; 0, 1).
def std_normal_pdf(x: f32) -> f32 =
  normal_pdf(x, cast(0.0, f32), cast(1.0, f32))

-- Standard normal cdf at x: Phi(x).
def std_normal_cdf(x: f32) -> f32 =
  normal_cdf(x, cast(0.0, f32), cast(1.0, f32))

-- Standard normal quantile (inverse CDF).
def std_normal_quantile(p: f32) -> f32 =
  normal_inv_cdf(p, cast(0.0, f32), cast(1.0, f32))

-- Exponential CDF at the half-life of rate=1: F(ln 2) = 0.5.
def exp_cdf_half_life() -> f32 =
  exponential_cdf(cast(0.6931472, f32), cast(1.0, f32))
