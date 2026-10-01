module Hello.Nautilus.Hypothesis
import Nautilus.Testing (z_statistic, z_p_value_two_sided, t_statistic_one_sample)
export (z_score, z_score_at_mean, z_p_two_sided_zero, t_one_sample, t_one_sample_at_mean)
def z_score(sample_mean: f32, pop_mean: f32, pop_std: f32, n: f32) -> f32 = z_statistic(sample_mean, pop_mean, pop_std, n)
def z_score_at_mean() -> f32 = z_statistic(50.0f32, 50.0f32, 10.0f32, 25.0f32)
def z_p_two_sided_zero() -> f32 = z_p_value_two_sided(0.0f32)
def t_one_sample(sample_mean: f32, sample_std: f32, n: f32, pop_mean: f32) -> f32 = t_statistic_one_sample(sample_mean, sample_std, n, pop_mean)
def t_one_sample_at_mean() -> f32 = t_statistic_one_sample(7.0f32, 2.0f32, 10.0f32, 7.0f32)
