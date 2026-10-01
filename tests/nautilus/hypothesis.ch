module Hello.Tests.Nautilus.Hypothesis
import Hello.Nautilus.Hypothesis (z_score_at_mean, z_p_two_sided_zero, t_one_sample_at_mean, z_score)
import Std.Test (assert_close)
def test_z_score_at_mean_zero() -> unit ! { Test } = assert_close(z_score_at_mean(), 0.0f32, 1e-6f32, "z = 0 when sample_mean = pop_mean")
def test_z_p_two_sided_at_zero() -> unit ! { Test } = assert_close(z_p_two_sided_zero(), 1.0f32, 0.00001f32, "two-sided p(z=0) = 1")
def test_t_one_sample_at_mean_zero() -> unit ! { Test } = assert_close(t_one_sample_at_mean(), 0.0f32, 1e-6f32, "t = 0 when sample_mean = pop_mean")
def test_z_score_one_sigma() -> unit ! { Test } = assert_close(z_score(51.0f32, 50.0f32, 10.0f32, 100.0f32), 1.0f32, 0.00001f32, "z-score = 1 at one SE above mean")
