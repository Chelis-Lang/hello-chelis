module Hello.Basics.HelloTensor

import Std.Tensor.Construct (to_tensor)
import Std.Test (assert_close_tensor)

// Element-wise add over a vector of length `n`.
//
// `n` is a named dimension. `add(x, y)` requires both operands to share the
// SAME named dim list and the same precision. There is no implicit
// broadcasting: passing `tensor[n, f32]` and `tensor[m, f32]` would be a
// compile error even if the runtime shapes happen to match.
def add_vec(x: tensor[n, f32], y: tensor[n, f32]) -> tensor[n, f32] =
  add(x, y)

def main() -> tensor[n, f32] = {
  a = to_tensor([1.0, 2.0, 3.0])
  b = to_tensor([4.0, 5.0, 6.0])
  add_vec(a, b)
}

def test_add_vec() -> unit ! { Test } = {
  out = main()
  expected = to_tensor([5.0, 7.0, 9.0])
  assert_close_tensor(out, expected, 1e-6, "add_vec_3")
}
