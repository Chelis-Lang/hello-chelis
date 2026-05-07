module CastLowers

-- cast(t, target_precision) lowering. v0.6.1 supports tensor casts to
-- f32, f64, bool, int8, int32, int64 (bf16 is reserved syntax but the
-- backend rejects it as unsupported). f32 -> f64 -> f32 is exact for
-- powers of two and small integers.

xs = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(4.0, f32)])
hi = cast(xs, f64)
back = cast(hi, f32)
