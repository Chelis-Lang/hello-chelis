module Hello.Tests.Coral.AdThroughDataFrame
import Hello.Coral.AdThroughDataFrame (frame_shape_check, simple_loss, dsimple_loss_dw)
import Std.Test (assert_eq, assert_close_tensor)
def reshape_to_one(s: tensor[f32]) -> tensor[1, f32] = insert(s, 0, 1i64)
def test_frame_shape_from_tensor() -> unit ! { Test } = {
  w = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
  assert_eq(frame_shape_check(w), cast(3, i64), "frame nrows == 3")
}
def test_simple_loss_value() -> unit ! { Test } = {
  w = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
  expected = to_tensor([cast(14.0, f32)])
  assert_close_tensor(reshape_to_one(simple_loss(w)), expected, cast(0.00001, f32), "loss == 14.0")
}
def test_dgrad_is_callable_in_typecheck() -> unit ! { Test } = {
  w = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
  assert_eq(frame_shape_check(w), cast(3, i64), "grad input has shape 3")
}
