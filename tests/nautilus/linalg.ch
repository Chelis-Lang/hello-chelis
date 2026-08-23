module Hello.Tests.Nautilus.LinAlg
import Hello.Nautilus.LinAlg (vec_norm, vec_dot, solve_diag_2x2)
import Std.Test (assert_close, assert_close_tensor)
def test_vec_norm_3_4_5() -> unit ! { Test } = {
  v = to_tensor([cast(3.0, f32), cast(4.0, f32)])
  assert_close(vec_norm(v), cast(5.0, f32), cast(1e-6, f32), "||(3,4)|| = 5")
}
def test_vec_dot_orthogonal() -> unit ! { Test } = {
  a = to_tensor([cast(1.0, f32), cast(0.0, f32)])
  b = to_tensor([cast(0.0, f32), cast(1.0, f32)])
  assert_close(vec_dot(a, b), cast(0.0, f32), cast(1e-6, f32), "e0 . e1 = 0")
}
def test_solve_diag_2x2() -> unit ! { Test } = {
  expected = to_tensor([cast(2.0, f32), cast(3.0, f32)])
  assert_close_tensor(solve_diag_2x2(), expected, cast(0.00001, f32), "solve diag 2x2")
}
