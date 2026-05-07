module Hello.Tests.Coral.AdThroughDataFrame

import Hello.Coral.AdThroughDataFrame (frame_shape_check, simple_loss, dsimple_loss_dw)
import Std.Test (assert_eq_int, assert_close, assert_close_tensor)

-- Structural test: building a 1-column Frame from a parameter tensor
-- gives nrows == numel(w).
def test_frame_shape_from_tensor() -> unit ! { Test } = {
  w = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
  assert_eq_int(frame_shape_check(w), cast(3, int64), "frame nrows == 3")
}

-- Loss value: sum(w*w) at w=[1, 2, 3] = 1 + 4 + 9 = 14.
def test_simple_loss_value() -> unit ! { Test } = {
  w = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
  assert_close(simple_loss(w), cast(14.0, f32), cast(1e-5, f32), "loss == 14.0")
}

-- d/dw [ sum(w * w) ] = 2 * w. At w=[1, 2, 3], gradient = [2, 4, 6].
def test_simple_loss_grad() -> unit ! { Test } = {
  w = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
  expected = to_tensor([cast(2.0, f32), cast(4.0, f32), cast(6.0, f32)])
  assert_close_tensor(dsimple_loss_dw(w), expected, cast(1e-5, f32), "grad == 2 * w")
}
