module Hello.Tests.Proofdemos.ProbabilityBudget
import Hello.Proofdemos.ProbabilityBudget (uniform_payout, normal_tail_reserve)
import Std.Test (assert_close)
def test_uniform_payout_middle() -> unit ! { Test } = assert_close(uniform_payout(5.0f32, 0.0f32, 10.0f32, 1000.0f32), 500.0f32, 0.001f32, "half the events exceed the middle threshold")
def test_uniform_payout_outside_support() -> unit ! { Test } = {
  _ = assert_close(uniform_payout(-1.0f32, 0.0f32, 10.0f32, 1000.0f32), 1000.0f32, 0.001f32, "below support pays the full budget")
  assert_close(uniform_payout(11.0f32, 0.0f32, 10.0f32, 1000.0f32), 0.0f32, 0.001f32, "above support pays nothing")
}
def test_normal_tail_reserve() -> unit ! { Test } = assert_close(normal_tail_reserve(0.0f32), 500.0f32, 0.01f32, "half of a standard normal lies above zero")
