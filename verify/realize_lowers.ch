module RealizeLowers

-- realize(e) forces evaluation of a deferred expression. Used in
-- production paths to pin a tensor at a specific point in the DAG.
-- The C backend lowers it; the IR evaluator currently doesn't.

xs = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
deferred = mul(copy(xs), xs)
materialized = realize(deferred)
