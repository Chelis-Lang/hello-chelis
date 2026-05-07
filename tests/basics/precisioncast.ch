module Hello.Tests.Basics.PrecisionCast

import Hello.Basics.PrecisionCast (round_scalar)
import Std.Test (assert_close)

-- The IR evaluator (`chelis test`) doesn't yet implement tensor-level
-- `cast`. `chelis check` validates the tensor demo in
-- src/basics/precisioncast.ch; here we exercise the scalar form.
--
-- f32 -> f64 -> f32 round-trip is lossless for representable values.

def test_round_15() -> unit ! { Test } =
  assert_close(round_scalar(cast(1.5, f32)), cast(1.5, f32), cast(1e-9, f32), "round_1p5")

def test_round_pi() -> unit ! { Test } =
  -- Approximate pi in f32; round-trip stays exact.
  assert_close(round_scalar(cast(3.14159, f32)), cast(3.14159, f32), cast(1e-6, f32), "round_pi")
