module Hello.Tests.Coral.AdThroughDataFrame
import Hello.Coral.AdThroughDataFrame (frame_shape_check, simple_loss, dsimple_loss_dw)
import Std.Test (assert_eq, assert_close_tensor)
def reshape_to_one(s: tensor[f32]) -> tensor[1, f32] = insert(s, 0, 1i64)
def test_frame_shape_from_tensor() -> unit ! { Test } = {
  w = to_tensor([1.0f32, 2.0f32, 3.0f32])
  assert_eq(frame_shape_check(w), 3i64, "frame nrows == 3")
}
def test_simple_loss_value() -> unit ! { Test } = {
  w = to_tensor([1.0f32, 2.0f32, 3.0f32])
  expected = to_tensor([14.0f32])
  assert_close_tensor(reshape_to_one(simple_loss(w)), expected, 0.00001f32, "loss == 14.0")
}
def test_dsimple_loss_dw_is_two_w() -> unit ! { Test } = {
  w = to_tensor([1.0f32, 2.0f32, 3.0f32])
  expected = to_tensor([2.0f32, 4.0f32, 6.0f32])
  assert_close_tensor(dsimple_loss_dw(w), expected, 0.00001f32, "dloss/dw == 2w")
}
