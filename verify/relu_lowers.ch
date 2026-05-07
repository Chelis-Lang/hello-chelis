module ReluLowers

-- Demonstrates that the tensor `relu` activation actually lowers to C
-- and runs. The IR evaluator (`chelis test`) doesn't ship `relu` as a
-- host kernel today; the C backend does.

xs = to_tensor([cast(-2.0, f32), cast(-0.5, f32), cast(0.0, f32), cast(0.5, f32), cast(2.0, f32)])
ys = relu(xs)
