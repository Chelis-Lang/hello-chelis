module ReluLowers
xs = to_tensor([cast(-2.0, f32), cast(-0.5, f32), cast(0.0, f32), cast(0.5, f32), cast(2.0, f32)])
ys = relu(xs)
