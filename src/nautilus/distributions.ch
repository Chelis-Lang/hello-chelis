module Hello.Nautilus.Distributions
import Nautilus.Distributions (normal_pdf, normal_cdf, normal_inv_cdf, exponential_cdf)
export (std_normal_pdf, std_normal_cdf, std_normal_quantile, exp_cdf_half_life)
def std_normal_pdf(x: f32) -> f32 = normal_pdf(x, 0.0f32, 1.0f32)
def std_normal_cdf(x: f32) -> f32 = normal_cdf(x, 0.0f32, 1.0f32)
def std_normal_quantile(p: f32) -> f32 = normal_inv_cdf(p, 0.0f32, 1.0f32)
def exp_cdf_half_life() -> f32 = exponential_cdf(0.6931472f32, 1.0f32)
