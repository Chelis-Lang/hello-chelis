module Hello.Nautilus.LinAlg
import Nautilus.LinAlg (matvec, inner_product, l2_norm_vec, solve_2x2)
export (vec_norm, vec_dot, mat_apply_2x2, solve_diag_2x2)
def vec_norm[n](v: &tensor[n, f32]) -> f32 = l2_norm_vec(v)
def vec_dot[n](a: &tensor[n, f32], b: &tensor[n, f32]) -> f32 = inner_product(a, b)
def mat_apply_2x2(m: &tensor[2, 2, f32], v: &tensor[2, f32]) -> tensor[2, f32] = matvec(m, v)
def solve_diag_2x2() -> tensor[2, f32] = {
  e0 = to_tensor([1.0f32, 0.0f32])
  e1 = to_tensor([0.0f32, 1.0f32])
  row0 = to_tensor([2.0f32, 0.0f32])
  row1 = to_tensor([0.0f32, 3.0f32])
  m0 = einsum("i,j->ij", e0, row0)
  m1 = einsum("i,j->ij", e1, row1)
  a = add(m0, m1)
  b = to_tensor([4.0f32, 9.0f32])
  solve_2x2(a, b)
}
