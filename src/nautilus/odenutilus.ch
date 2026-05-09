module Hello.Nautilus.OdeNutilus
import Nautilus.Ode (rk4_solve, euler_solve)
export (decay_rk4, decay_euler, exp_growth_rk4)
def decay(y: f32, t: f32) -> f32 = neg(y)
def growth(y: f32, t: f32) -> f32 = y
def decay_rk4() -> f32 = rk4_solve(decay, cast(1.0, f32), cast(0.0, f32), cast(1.0, f32), cast(100, int64))
def decay_euler() -> f32 = euler_solve(decay, cast(1.0, f32), cast(0.0, f32), cast(1.0, f32), cast(2000, int64))
def exp_growth_rk4() -> f32 = rk4_solve(growth, cast(1.0, f32), cast(0.0, f32), cast(1.0, f32), cast(100, int64))
