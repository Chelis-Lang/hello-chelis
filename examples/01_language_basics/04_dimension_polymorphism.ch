module Hello.Basics.DimPoly

import Std.Tensor.Construct (to_tensor)
import Std.Test (assert_close_tensor)

// Bracketed dim parameters introduce unification variables. `transpose`
// here works for any pair of dims `[a, b]` — the type checker proves at
// each call site that the named dims line up.
def transpose[a, b](x: tensor[a, b, f32]) -> tensor[b, a, f32] =
  permute(x, 1, 0)

// And rank-1 dim polymorphism — the identity that doesn't care which named
// dim it gets.
def identity_dim[a](x: tensor[a, f32]) -> tensor[a, f32] = x

def test_transpose_2x3() -> unit ! { Test } = {
  // [[1, 2, 3],
  //  [4, 5, 6]]
  m = to_tensor([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]])
  // -> [[1, 4],
  //     [2, 5],
  //     [3, 6]]
  out = transpose(m)
  expected = to_tensor([[1.0, 4.0], [2.0, 5.0], [3.0, 6.0]])
  assert_close_tensor(out, expected, 1e-6, "transpose_2x3")
}

def test_identity_dim() -> unit ! { Test } = {
  v = to_tensor([7.0, 8.0, 9.0])
  out = identity_dim(v)
  assert_close_tensor(out, v, 1e-6, "identity_dim")
}
