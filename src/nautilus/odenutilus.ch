module Hello.Nautilus.OdeNutilus
import Nautilus.Ode (rk4_solve, euler_solve)
export (decay_rk4, decay_euler, exp_growth_rk4)
def decay(y: f32, t: f32) -> f32 = neg(y)
def growth(y: f32, t: f32) -> f32 = y
def decay_rk4() -> f32 = rk4_solve(decay, 1.0f32, 0.0f32, 1.0f32, 100i64)
def decay_euler() -> f32 = euler_solve(decay, 1.0f32, 0.0f32, 1.0f32, 2000i64)
def exp_growth_rk4() -> f32 = rk4_solve(growth, 1.0f32, 0.0f32, 1.0f32, 100i64)
