module Hello.Tests.Nautilus.LinAlg
import Hello.Nautilus.LinAlg (vec_norm, vec_dot, solve_diag_2x2)
import Std.Test (assert_close, assert_close_tensor)
def test_vec_norm_3_4_5() -> unit ! { Test } = {
  v = to_tensor([3.0f32, 4.0f32])
  assert_close(vec_norm(v), 5.0f32, 1e-6f32, "||(3,4)|| = 5")
}
def test_vec_dot_orthogonal() -> unit ! { Test } = {
  a = to_tensor([1.0f32, 0.0f32])
  b = to_tensor([0.0f32, 1.0f32])
  assert_close(vec_dot(a, b), 0.0f32, 1e-6f32, "e0 . e1 = 0")
}
def test_solve_diag_2x2() -> unit ! { Test } = {
  expected = to_tensor([2.0f32, 3.0f32])
  assert_close_tensor(solve_diag_2x2(), expected, 0.00001f32, "solve diag 2x2")
}
