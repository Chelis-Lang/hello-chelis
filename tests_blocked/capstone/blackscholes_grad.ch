module Hello.TestsBlocked.Capstone.BlackScholes_Grad
import Hello.Capstone.BlackScholes (delta)
import Std.Test (assert_close)
def test_delta_atm() -> unit ! { Test } = assert_close(delta(cast(100.0, f32), cast(100.0, f32), cast(0.05, f32), cast(0.2, f32), cast(1.0, f32)), cast(0.6368, f32), cast(0.01, f32), "bs_delta_atm")
