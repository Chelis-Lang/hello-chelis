module Hello.Nautilus.Interpolation

import Std.Tensor.Construct (to_tensor)
import Nautilus.Interpolate (linear_uniform, cubic_hermite)
import Std.Test (assert_close)

// y at xs known. Interpolate at x_query = 1.5 between xs=[0,1,2,3] with
// ys = [0, 1, 4, 9] (i.e. y = x^2 at integer points).
// Linear interp at 1.5: average of y(1)=1 and y(2)=4 -> 2.5.
// Cubic Hermite interp at 1.5: closer to 2.25 (the exact x^2 value).

def linear_at_1p5() -> f32 = {
  ys = to_tensor([0.0, 1.0, 4.0, 9.0])
  linear_uniform(ys, cast(0.0, f32), cast(3.0, f32), cast(1.5, f32))
}

def cubic_at_1p5() -> f32 = {
  xs = to_tensor([0.0, 1.0, 2.0, 3.0])
  ys = to_tensor([0.0, 1.0, 4.0, 9.0])
  cubic_hermite(xs, ys, cast(1.5, f32))
}

def test_linear() -> unit ! { Test } =
  assert_close(linear_at_1p5(), 2.5, 1e-6, "linear_at_1p5")

def test_cubic_close_to_quadratic() -> unit ! { Test } =
  // Cubic Hermite over evenly-spaced quadratic samples should land near
  // the true 2.25 within 0.1.
  assert_close(cubic_at_1p5(), 2.25, 0.1, "cubic_at_1p5")
