module RealizeLowers
xs = to_tensor([1.0f32, 2.0f32, 3.0f32])
deferred = mul(xs, xs)
materialized = realize(deferred)
