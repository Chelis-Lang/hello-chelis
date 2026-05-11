module Hello.Nautilus.LinAlg
import Nautilus.LinAlg (matvec, inner_product, l2_norm_vec, solve_2x2)
export (vec_norm, vec_dot, mat_apply_2x2, solve_diag_2x2)
def vec_norm(v: &tensor[n, f32]) -> f32 = l2_norm_vec(v)
def vec_dot(a: &tensor[n, f32], b: &tensor[n, f32]) -> f32 = inner_product(a, b)
def mat_apply_2x2(m: &tensor[2, 2, f32], v: &tensor[2, f32]) -> tensor[2, f32] = matvec(m, v)
def solve_diag_2x2() -> tensor[2, f32] = {
  e0 = to_tensor([cast(1.0, f32), cast(0.0, f32)])
  e1 = to_tensor([cast(0.0, f32), cast(1.0, f32)])
  row0 = to_tensor([cast(2.0, f32), cast(0.0, f32)])
  row1 = to_tensor([cast(0.0, f32), cast(3.0, f32)])
  m0 = einsum("i,j->ij", e0, row0)
  m1 = einsum("i,j->ij", e1, row1)
  a = add(m0, m1)
  b = to_tensor([cast(4.0, f32), cast(9.0, f32)])
  __borrow_migration_out_0 = solve_2x2(a, b)
  __borrow_migration_out_0
}
