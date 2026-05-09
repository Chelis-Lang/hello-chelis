module ReluThenSigmoid
xs = to_tensor([cast(-1.0, f32), cast(0.0, f32), cast(1.0, f32)])
relud = relu(xs)
out = sigmoid(relud)
