module ReluThenSigmoid
xs = to_tensor([-1.0f32, 0.0f32, 1.0f32])
relud = relu(xs)
out = sigmoid(relud)
