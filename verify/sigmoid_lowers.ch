module SigmoidLowers

-- sigmoid(x) lowered to C. sigmoid(0) == 0.5 is the canonical check.

xs = to_tensor([cast(-2.0, f32), cast(0.0, f32), cast(2.0, f32)])
ys = sigmoid(xs)
