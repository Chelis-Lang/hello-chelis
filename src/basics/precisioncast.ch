module Hello.Basics.PrecisionCast

export (to_f64_scalar, to_f32_scalar, round_scalar, to_f64, to_f32, low_then_high)

-- Chelis NEVER promotes precision implicitly. `add(f32, f64)` is a
-- compile error. The fix is `cast(x, target_precision)`, a language
-- transform that changes precision while preserving the dim list.
--
-- (The compiler at v0.6.1 supports f32, f64, int8, int32, int64, bool
-- as cast targets; bf16 is the next addition on the roadmap.)

-- Scalar variants (run in the IR evaluator):
def to_f64_scalar(x: f32) -> f64 = cast(x, f64)
def to_f32_scalar(x: f64) -> f32 = cast(x, f32)
def round_scalar(x: f32) -> f32 = x |> to_f64_scalar |> to_f32_scalar

-- Tensor variants (compile via chelis check + chelis build; the in-process
-- evaluator at v0.6.1 doesn't yet implement tensor-level casts):
def to_f64(x: tensor[n, f32]) -> tensor[n, f64] = cast(x, f64)
def to_f32(x: tensor[n, f64]) -> tensor[n, f32] = cast(x, f32)
def low_then_high(x: tensor[n, f32]) -> tensor[n, f32] =
  x |> to_f64 |> to_f32
