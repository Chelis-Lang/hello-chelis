module Hello.Tests.Basics.PrecisionCast
import Hello.Basics.PrecisionCast (round_scalar)
import Std.Test (assert_close)
def test_round_15() -> unit ! { Test } = assert_close(round_scalar(1.5f32), 1.5f32, 1e-9f32, "round_1p5")
def test_round_pi() -> unit ! { Test } = assert_close(round_scalar(3.14159f32), 3.14159f32, 1e-6f32, "round_pi")
