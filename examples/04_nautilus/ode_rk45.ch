module Hello.Nautilus.OdeRk45

import Nautilus.ODE (rk4_solve, rk45_endpoint)
import Std.Test (assert_close)

// dy/dt = -y, y(0) = 1. Exact: y(t) = exp(-t).
// At t = 1, y = 1/e ~= 0.367879
def rhs(t: tensor[f32], y: tensor[f32]) -> tensor[f32] = neg(y)

def test_rk4_solve() -> unit ! { Test } = {
  y_end = rk4_solve(rhs, cast(0.0, f32), cast(1.0, f32), cast(1.0, f32), cast(1000, int64))
  assert_close(y_end, 0.367879, 1e-4, "rk4_decay")
}

def test_rk45_endpoint() -> unit ! { Test } = {
  y_end = rk45_endpoint(rhs, cast(0.0, f32), cast(1.0, f32), cast(1.0, f32), cast(1e-6, f32), cast(1000, int64))
  assert_close(y_end, 0.367879, 1e-4, "rk45_decay")
}
