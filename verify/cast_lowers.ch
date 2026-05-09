module CastLowers
xs = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(4.0, f32)])
hi = cast(xs, f64)
back = cast(hi, f32)
