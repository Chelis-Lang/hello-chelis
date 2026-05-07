module Hello.Nautilus.Interpolation

import Nautilus.Interpolation (linear_interp_uniform, cubic_hermite)

export (linear_at_query, hermite_unit_segment, hermite_endpoint)

-- Linearly interpolate ys = [0, 1, 4, 9] sampled at x in [0, 3] (uniform grid)
-- at the query point x_q.
def linear_at_query(x_q: f32) -> f32 = {
  ys = to_tensor([cast(0.0, f32), cast(1.0, f32), cast(4.0, f32), cast(9.0, f32)])
  linear_interp_uniform(ys, cast(0.0, f32), cast(3.0, f32), x_q)
}

-- Cubic Hermite over [0, 1] with y(0)=0, y(1)=1, m0=0, m1=0.
-- The unique cubic with those boundary conditions is 3 t^2 - 2 t^3.
-- At t=0.5 it equals 0.5.
def hermite_unit_segment(x_q: f32) -> f32 =
  cubic_hermite(cast(0.0, f32), cast(1.0, f32),
                cast(0.0, f32), cast(1.0, f32),
                cast(0.0, f32), cast(0.0, f32),
                x_q)

-- Hermite at the right endpoint must reproduce y1.
def hermite_endpoint() -> f32 =
  cubic_hermite(cast(0.0, f32), cast(2.0, f32),
                cast(3.0, f32), cast(7.0, f32),
                cast(0.5, f32), cast(0.5, f32),
                cast(2.0, f32))
