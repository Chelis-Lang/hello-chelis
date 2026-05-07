module Hello.Basics.PrecisionCast

import Std.Tensor.Construct (to_tensor)
import Std.Test (assert_close_tensor, assert_close)

// Chelis does NOT silently promote precisions. `add(f32_tensor, bf16_tensor)`
// is a compile error. The fix is `cast(x, target_precision)`, which leaves
// dimensions intact and only changes the precision component of the type.

def f32_to_bf16(x: tensor[n, f32]) -> tensor[n, bf16] =
  cast(x, bf16)

def bf16_to_f32(x: tensor[n, bf16]) -> tensor[n, f32] =
  cast(x, f32)

// A typical pattern: do the heavy compute in lower precision, accumulate
// the loss in f32. The cast is what tells the type checker (and the
// reader) that the precision flip is intentional.
def low_then_high(x: tensor[n, f32]) -> tensor[f32] = {
  low = cast(x, bf16)
  squared = mul(low, low)
  back = cast(squared, f32)
  sum(back, 0)
}

def test_roundtrip() -> unit ! { Test } = {
  x = to_tensor([1.0, 2.0, 4.0])
  back = bf16_to_f32(f32_to_bf16(x))
  // bf16 has 7-8 bits of mantissa; round-trip loss for these values is
  // well within 1e-2.
  assert_close_tensor(back, x, 1e-2, "bf16_roundtrip")
}

def test_low_then_high() -> unit ! { Test } = {
  x = to_tensor([1.0, 2.0, 3.0])
  out = low_then_high(x)
  // sum of squares = 14
  assert_close(out, 14.0, 0.5, "low_then_high")
}

// Note: there is also a deliberately-broken variant tested under
// tests/expected/precision_mismatch_should_fail.json which asserts that
// the compiler rejects an unwrapped mixed-precision program with a
// `precision_mismatch` error and a suggestion to insert `cast`.
