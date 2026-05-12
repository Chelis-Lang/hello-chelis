module Hello.Basics.PrecisionCast
export (to_f64_scalar, to_f32_scalar, round_scalar, to_f64, to_f32, low_then_high)
def to_f64_scalar(x: f32) -> f64 = cast(x, f64)
def to_f32_scalar(x: f64) -> f32 = cast(x, f32)
def round_scalar(x: f32) -> f32 = x |> to_f64_scalar |> to_f32_scalar
def to_f64(x: tensor[n, f32]) -> tensor[n, f64] = cast(x, f64)
def to_f32(x: tensor[n, f64]) -> tensor[n, f32] = cast(x, f32)
def low_then_high(x: tensor[n, f32]) -> tensor[n, f32] = x |> to_f64 |> to_f32
