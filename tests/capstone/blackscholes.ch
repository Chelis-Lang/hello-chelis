module Hello.Tests.Capstone.BlackScholes
import Hello.Capstone.BlackScholes (call_price)
import Std.Test (assert_close)
def test_call_atm() -> unit ! { Test } = assert_close(call_price(cast(100.0, f32), cast(100.0, f32), cast(0.05, f32), cast(0.2, f32), cast(1.0, f32)), cast(10.4506, f32), cast(0.05, f32), "bs_call_atm")
