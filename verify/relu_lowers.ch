module ReluLowers
xs = to_tensor([-2.0f32, -0.5f32, 0.0f32, 0.5f32, 2.0f32])
ys = relu(xs)
