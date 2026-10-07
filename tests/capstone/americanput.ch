module Hello.Tests.Capstone.AmericanPut
import Hello.Capstone.AmericanPut (european_put, tree_put, critical_price, approximate_put)
import Std.Test (assert_close, assert_true)
def test_european_put() -> unit ! { Test } = assert_close(european_put(100.0f32, 100.0f32, 0.05f32, 0.2f32, 1.0f32), 5.573526f32, 0.0001f32, "Black-Scholes put")
def test_early_exercise_has_value() -> unit ! { Test } = assert_true(gt(tree_put(100.0f32, 100.0f32, 0.05f32, 0.2f32, 1.0f32, 50i64), add(european_put(100.0f32, 100.0f32, 0.05f32, 0.2f32, 1.0f32), 0.4f32)), "the American put is worth more than the European")
def test_tree_put() -> unit ! { Test } = {
  p = tree_put(100.0f32, 100.0f32, 0.05f32, 0.2f32, 1.0f32, 50i64)
  _ = assert_close(p, 6.073728f32, 0.0005f32, "the 50-step CRR value")
  assert_close(p, 6.08999f32, 0.03f32, "within 3 cents of the converged price")
}
def test_critical_price() -> unit ! { Test } = assert_close(critical_price(100.0f32, 0.05f32, 0.2f32, 1.0f32), 81.695f32, 0.01f32, "exercise below S** = 81.695")
def test_approximation_agrees_with_tree() -> unit ! { Test } = assert_close(approximate_put(100.0f32, 100.0f32, 0.05f32, 0.2f32, 1.0f32), 6.0976f32, 0.001f32, "Barone-Adesi-Whaley")
def test_deep_in_the_money_exercises() -> unit ! { Test } = assert_close(approximate_put(70.0f32, 100.0f32, 0.05f32, 0.2f32, 1.0f32), 30.0f32, 0.00001f32, "below S** the put is worth its intrinsic value")
