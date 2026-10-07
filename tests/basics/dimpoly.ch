module Hello.Tests.Basics.DimPoly
import Hello.Basics.DimPoly (identity_dim, scaled)
import Std.Test (assert_close_tensor)
def test_identity() -> unit ! { Test } = {
  v = to_tensor([7.0f32, 8.0f32, 9.0f32])
  expected = to_tensor([7.0f32, 8.0f32, 9.0f32])
  assert_close_tensor(identity_dim(v), expected, 1e-6f32, "identity")
}
def test_scaled() -> unit ! { Test } = {
  v = to_tensor([1.0f32, 2.0f32, 3.0f32])
  expected = to_tensor([2.0f32, 4.0f32, 6.0f32])
  assert_close_tensor(scaled(v), expected, 1e-6f32, "scaled_3")
}
