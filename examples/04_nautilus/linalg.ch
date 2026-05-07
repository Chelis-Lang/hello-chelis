module Hello.Nautilus.LinAlg

import Std.Tensor.Construct (to_tensor)
import Nautilus.LinAlg (solve, cholesky, cg, det_2x2, inverse_2x2)
import Std.Test (assert_close, assert_close_tensor)

// Solve a 2x2 SPD system: A x = b
//   A = [[4, 1], [1, 3]]
//   b = [1, 2]
//   exact x = [1/11, 7/11] ~= [0.0909, 0.6364]
def small_solve() -> tensor[n, f32] = {
  a = to_tensor([[4.0, 1.0], [1.0, 3.0]])
  b = to_tensor([1.0, 2.0])
  solve(a, b)
}

// Cholesky factor of A = [[4, 1], [1, 3]] is L = [[2, 0], [0.5, sqrt(2.75)]]
def small_chol() -> tensor[n, m, f32] = {
  a = to_tensor([[4.0, 1.0], [1.0, 3.0]])
  cholesky(a)
}

// Conjugate gradient: same A, b. CG converges in <= n iterations on SPD.
def small_cg() -> tensor[n, f32] = {
  a = to_tensor([[4.0, 1.0], [1.0, 3.0]])
  b = to_tensor([1.0, 2.0])
  x0 = to_tensor([0.0, 0.0])
  cg(a, b, x0, cast(20, int64), cast(1e-10, f32))
}

def test_solve() -> unit ! { Test } = {
  out = small_solve()
  expected = to_tensor([cast(1.0 / 11.0, f32), cast(7.0 / 11.0, f32)])
  assert_close_tensor(out, expected, 1e-4, "small_solve")
}

def test_cg_matches_solve() -> unit ! { Test } = {
  cg_x = small_cg()
  exact = small_solve()
  assert_close_tensor(cg_x, exact, 1e-4, "cg_matches_solve")
}

def test_2x2_det_and_inverse() -> unit ! { Test } = {
  m = to_tensor([[4.0, 1.0], [1.0, 3.0]])
  d = det_2x2(copy(m))
  // det = 12 - 1 = 11
  assert_close(d, 11.0, 1e-6, "det_2x2")
  inv = inverse_2x2(m)
  expected = to_tensor([[cast(3.0 / 11.0, f32), cast(0.0 - 1.0 / 11.0, f32)], [cast(0.0 - 1.0 / 11.0, f32), cast(4.0 / 11.0, f32)]])
  assert_close_tensor(inv, expected, 1e-4, "inv_2x2")
}
