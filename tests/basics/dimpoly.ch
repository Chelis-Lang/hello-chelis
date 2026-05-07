module Hello.Tests.Basics.DimPoly

import Hello.Basics.DimPoly (identity_dim, scaled)
import Std.Test (assert_close_tensor)

def test_identity() -> unit ! { Test } = {
  v = to_tensor([cast(7.0, f32), cast(8.0, f32), cast(9.0, f32)])
  expected = to_tensor([cast(7.0, f32), cast(8.0, f32), cast(9.0, f32)])
  assert_close_tensor(identity_dim(v), expected, cast(1e-6, f32), "identity")
}

def test_scaled() -> unit ! { Test } = {
  v = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
  expected = to_tensor([cast(2.0, f32), cast(4.0, f32), cast(6.0, f32)])
  assert_close_tensor(scaled(v), expected, cast(1e-6, f32), "scaled_3")
}
