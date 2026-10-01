module Hello.Tests.Capstone.AmericanPut
import Hello.Capstone.AmericanPut (european_put, tree_put, critical_price, approximate_put)
import Std.Test (assert_close, assert_true)
def test_european_put() -> unit ! { Test } = assert_close(european_put(cast(100.0, f32), cast(100.0, f32), cast(0.05, f32), cast(0.2, f32), cast(1.0, f32)), cast(5.573526, f32), cast(0.0001, f32), "Black-Scholes put")
def test_early_exercise_has_value() -> unit ! { Test } = assert_true(gt(tree_put(cast(100.0, f32), cast(100.0, f32), cast(0.05, f32), cast(0.2, f32), cast(1.0, f32), cast(50, i64)), add(european_put(cast(100.0, f32), cast(100.0, f32), cast(0.05, f32), cast(0.2, f32), cast(1.0, f32)), cast(0.4, f32))), "the American put is worth more than the European")
def test_tree_put() -> unit ! { Test } = assert_close(tree_put(cast(100.0, f32), cast(100.0, f32), cast(0.05, f32), cast(0.2, f32), cast(1.0, f32), cast(50, i64)), cast(6.08999, f32), cast(0.03, f32), "a 50-step tree is within 3 cents of the converged price")
def test_critical_price() -> unit ! { Test } = assert_close(critical_price(cast(100.0, f32), cast(0.05, f32), cast(0.2, f32), cast(1.0, f32)), cast(81.695, f32), cast(0.01, f32), "exercise below S** = 81.695")
def test_approximation_agrees_with_tree() -> unit ! { Test } = assert_close(approximate_put(cast(100.0, f32), cast(100.0, f32), cast(0.05, f32), cast(0.2, f32), cast(1.0, f32)), cast(6.0976, f32), cast(0.001, f32), "Barone-Adesi-Whaley")
def test_deep_in_the_money_exercises() -> unit ! { Test } = assert_close(approximate_put(cast(70.0, f32), cast(100.0, f32), cast(0.05, f32), cast(0.2, f32), cast(1.0, f32)), cast(30.0, f32), cast(0.00001, f32), "below S** the put is worth its intrinsic value")
