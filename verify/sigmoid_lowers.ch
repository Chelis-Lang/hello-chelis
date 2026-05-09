module SigmoidLowers
xs = to_tensor([cast(-2.0, f32), cast(0.0, f32), cast(2.0, f32)])
ys = sigmoid(xs)
