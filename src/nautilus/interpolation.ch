module Hello.Nautilus.Interpolation
import Nautilus.Interpolation (linear_interp_uniform, cubic_hermite)
export (linear_at_query, hermite_unit_segment, hermite_endpoint)
def linear_at_query(x_q: f32) -> f32 = {
  ys = to_tensor([0.0f32, 1.0f32, 4.0f32, 9.0f32])
  linear_interp_uniform(ys, 0.0f32, 3.0f32, x_q)
}
def hermite_unit_segment(x_q: f32) -> f32 = cubic_hermite(0.0f32, 1.0f32, 0.0f32, 1.0f32, 0.0f32, 0.0f32, x_q)
def hermite_endpoint() -> f32 = cubic_hermite(0.0f32, 2.0f32, 3.0f32, 7.0f32, 0.5f32, 0.5f32, 2.0f32)
