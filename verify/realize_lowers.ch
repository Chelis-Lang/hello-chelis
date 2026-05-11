module RealizeLowers
xs = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
deferred = mul(xs, xs)
materialized = realize(deferred)
