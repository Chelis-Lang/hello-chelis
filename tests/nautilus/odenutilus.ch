module Hello.Tests.Nautilus.OdeNutilus
import Hello.Nautilus.OdeNutilus (decay_rk4, decay_euler, exp_growth_rk4)
import Std.Test (assert_close)
def test_decay_rk4() -> unit ! { Test } = assert_close(decay_rk4(), cast(0.36787944, f32), cast(0.0001, f32), "rk4 dy/dt = -y, y(1) = 1/e")
def test_decay_euler() -> unit ! { Test } = assert_close(decay_euler(), cast(0.36787944, f32), cast(0.001, f32), "euler dy/dt = -y, y(1) ~ 1/e")
def test_exp_growth_rk4() -> unit ! { Test } = assert_close(exp_growth_rk4(), cast(2.7182817, f32), cast(0.0001, f32), "rk4 dy/dt = y, y(1) = e")
