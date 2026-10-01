module CastLowers
xs = to_tensor([1.0f32, 2.0f32, 4.0f32])
hi = cast(xs, f64)
back = cast(hi, f32)
