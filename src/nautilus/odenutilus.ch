module Hello.Nautilus.OdeNutilus

import Nautilus.Ode (rk4_solve, euler_solve)

export (decay_rk4, decay_euler, exp_growth_rk4)

-- y' = -y. Closed-form: y(t) = y0 * exp(-t).
def decay(y: f32, t: f32) -> f32 = neg(y)

-- y' = y. Closed-form: y(t) = y0 * exp(t).
def growth(y: f32, t: f32) -> f32 = y

-- Solve y' = -y, y(0) = 1, t = 1; expect 1/e ~ 0.36787944.
def decay_rk4() -> f32 =
  rk4_solve(decay, cast(1.0, f32), cast(0.0, f32), cast(1.0, f32), cast(100, int64))

-- Same problem, Euler integrator.
def decay_euler() -> f32 =
  euler_solve(decay, cast(1.0, f32), cast(0.0, f32), cast(1.0, f32), cast(2000, int64))

-- y' = y, y(0) = 1, t = 1; expect e ~ 2.71828.
def exp_growth_rk4() -> f32 =
  rk4_solve(growth, cast(1.0, f32), cast(0.0, f32), cast(1.0, f32), cast(100, int64))
