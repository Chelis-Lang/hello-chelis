module Hello.Nautilus.Interpolation
import Nautilus.Interpolation (linear_interp_uniform, cubic_hermite)
export (linear_at_query, hermite_unit_segment, hermite_endpoint)
def linear_at_query(x_q: f32) -> f32 = {
  ys = to_tensor([cast(0.0, f32), cast(1.0, f32), cast(4.0, f32), cast(9.0, f32)])
  __borrow_migration_out_0 = linear_interp_uniform(ys, cast(0.0, f32), cast(3.0, f32), x_q)
  __borrow_migration_out_0
}
def hermite_unit_segment(x_q: f32) -> f32 = cubic_hermite(cast(0.0, f32), cast(1.0, f32), cast(0.0, f32), cast(1.0, f32), cast(0.0, f32), cast(0.0, f32), x_q)
def hermite_endpoint() -> f32 = cubic_hermite(cast(0.0, f32), cast(2.0, f32), cast(3.0, f32), cast(7.0, f32), cast(0.5, f32), cast(0.5, f32), cast(2.0, f32))
