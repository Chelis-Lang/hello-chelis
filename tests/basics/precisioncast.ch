module Hello.Tests.Basics.PrecisionCast

import Hello.Basics.PrecisionCast (low_then_high)
import Std.Test (assert_close_tensor)

def test_round_trip() -> unit ! { Test } = {
  x = to_tensor([cast(1.5, f32), cast(2.25, f32), cast(4.0, f32)])
  -- f32 -> f64 -> f32 is lossless for these representable values
  expected = to_tensor([cast(1.5, f32), cast(2.25, f32), cast(4.0, f32)])
  assert_close_tensor(low_then_high(x), expected, cast(1e-6, f32), "f32_f64_round_trip")
}
