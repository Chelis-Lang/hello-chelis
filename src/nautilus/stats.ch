module Hello.Nautilus.Stats

import Nautilus.Stats (mean_vec, variance_vec, std_vec, median_vec, quantile_vec, correlation_scalar)

export (sample_mean, sample_var, sample_std, sample_median, sample_quartile_low, sample_correlation)

-- Sample mean of a vector.
def sample_mean(v: tensor[n, f32]) -> f32 =
  mean_vec(v)

-- Sample variance (ddof = 1, Bessel-corrected).
def sample_var(v: tensor[n, f32]) -> f32 =
  variance_vec(v, cast(1, int64))

-- Sample standard deviation (ddof = 1).
def sample_std(v: tensor[n, f32]) -> f32 =
  std_vec(v, cast(1, int64))

-- Median of a sample.
def sample_median(v: tensor[n, f32]) -> f32 =
  median_vec(v)

-- 25% quantile of a sample.
def sample_quartile_low(v: tensor[n, f32]) -> f32 =
  quantile_vec(v, cast(0.25, f32))

-- Pearson correlation coefficient of two equal-length samples.
def sample_correlation(a: tensor[n, f32], b: tensor[n, f32]) -> f32 =
  correlation_scalar(a, b)
