module Hello.Nautilus.Hypothesis

import Nautilus.Testing (z_statistic, z_p_value_two_sided, t_statistic_one_sample)

export (z_score, z_score_at_mean, z_p_two_sided_zero, t_one_sample, t_one_sample_at_mean)

-- Z-score for a sample mean against a population.
def z_score(sample_mean: f32, pop_mean: f32, pop_std: f32, n: f32) -> f32 =
  z_statistic(sample_mean, pop_mean, pop_std, n)

-- When the sample mean equals the population mean, z = 0.
def z_score_at_mean() -> f32 =
  z_statistic(cast(50.0, f32), cast(50.0, f32), cast(10.0, f32), cast(25.0, f32))

-- Two-sided p-value for z = 0 should be 1.
def z_p_two_sided_zero() -> f32 =
  z_p_value_two_sided(cast(0.0, f32))

-- One-sample t-statistic.
def t_one_sample(sample_mean: f32, sample_std: f32, n: f32, pop_mean: f32) -> f32 =
  t_statistic_one_sample(sample_mean, sample_std, n, pop_mean)

-- Sample mean = population mean -> t = 0.
def t_one_sample_at_mean() -> f32 =
  t_statistic_one_sample(cast(7.0, f32), cast(2.0, f32), cast(10.0, f32), cast(7.0, f32))
