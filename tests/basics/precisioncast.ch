module Hello.Tests.Basics.PrecisionCast
import Hello.Basics.PrecisionCast (round_scalar)
import Std.Test (assert_close)
def test_round_15() -> unit ! { Test } = assert_close(round_scalar(cast(1.5, f32)), cast(1.5, f32), cast(0.000000001, f32), "round_1p5")
def test_round_pi() -> unit ! { Test } = assert_close(round_scalar(cast(3.14159, f32)), cast(3.14159, f32), cast(0.000001, f32), "round_pi")
