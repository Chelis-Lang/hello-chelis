module ReluThenSigmoid

-- Compose two tensor activations through the C backend: relu first,
-- then sigmoid. For input [-1, 0, 1]:
--   relu     -> [0, 0, 1]
--   sigmoid  -> [0.5, 0.5, ~0.7310586]
-- Direct call form rather than pipe — the pipe-of-tensor-kernels path
-- doesn't preserve the value shape through codegen on v0.6.1.

xs = to_tensor([cast(-1.0, f32), cast(0.0, f32), cast(1.0, f32)])
relud = relu(xs)
out = sigmoid(relud)
