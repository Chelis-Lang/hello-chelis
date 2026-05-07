module Hello.Tests.Nautilus.OdeNutilus

import Hello.Nautilus.OdeNutilus (decay_rk4, decay_euler, exp_growth_rk4)
import Std.Test (assert_close)

-- 1/e ~ 0.36787944
def test_decay_rk4() -> unit ! { Test } =
  assert_close(decay_rk4(), cast(0.36787944, f32), cast(1.0e-4, f32), "rk4 dy/dt = -y, y(1) = 1/e")

def test_decay_euler() -> unit ! { Test } =
  -- Euler is O(h) so we use a looser tolerance with many steps.
  assert_close(decay_euler(), cast(0.36787944, f32), cast(1.0e-3, f32), "euler dy/dt = -y, y(1) ~ 1/e")

-- e ~ 2.71828183
def test_exp_growth_rk4() -> unit ! { Test } =
  assert_close(exp_growth_rk4(), cast(2.7182817, f32), cast(1.0e-4, f32), "rk4 dy/dt = y, y(1) = e")
