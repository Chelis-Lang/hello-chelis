module Hello.Basics.PrecisionCast

export (to_f64, to_f32, low_then_high)

-- Chelis NEVER promotes precision implicitly. `add(f32_t, f64_t)` is a
-- compile error. The fix is `cast(x, target_precision)`, a language
-- transform that changes precision while preserving the dim list.
--
-- (The compiler at v0.6.1 supports f32, f64, int8, int32, int64, bool
-- as cast targets; bf16 is the next addition on the roadmap.)

def to_f64(x: tensor[n, f32]) -> tensor[n, f64] =
  cast(x, f64)

def to_f32(x: tensor[n, f64]) -> tensor[n, f32] =
  cast(x, f32)

-- Round-trip via the pipe operator: f32 -> f64 -> f32 in one chain.
-- Both casts are explicit; the compiler emits no implicit conversions.
def low_then_high(x: tensor[n, f32]) -> tensor[n, f32] =
  x |> to_f64 |> to_f32
