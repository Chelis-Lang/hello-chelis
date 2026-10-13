module Hello.Tests.Basics.QuadraticDescent
import Hello.Basics.QuadraticDescent (quadratic, quadratic_gradient, gradient_step)
import Std.Test (assert_close)
def test_gradient_step() -> unit ! { Test } = {
  _ = assert_close(quadratic_gradient(5.0f32), 4.0f32, 1e-6f32, "quadratic gradient")
  _ = assert_close(gradient_step(5.0f32, 0.5f32), 3.0f32, 1e-6f32, "half step reaches minimizer")
  assert_close(quadratic(gradient_step(5.0f32, 0.5f32)), 7.0f32, 1e-6f32, "half step reaches minimum")
}
def test_quarter_step_descends_from_left() -> unit ! { Test } = {
  _ = assert_close(quadratic_gradient(1.0f32), -4.0f32, 1e-6f32, "gradient left of minimizer")
  _ = assert_close(gradient_step(1.0f32, 0.25f32), 2.0f32, 1e-6f32, "quarter step from left")
  assert_close(quadratic(gradient_step(1.0f32, 0.25f32)), 8.0f32, 1e-6f32, "quarter step descends")
}
