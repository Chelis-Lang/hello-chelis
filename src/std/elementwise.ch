module Hello.Std.Elementwise
export (clamp_nonneg, clamp_then_logistic, logistic_vec, tanh_vec, standardize, rms_normalize)
def clamp_nonneg[n](x: &tensor[n, f32]) -> tensor[n, f32] = relu(x)
def clamp_then_logistic[n](x: &tensor[n, f32]) -> tensor[n, f32] = x |> relu |> sigmoid
def logistic_vec[n](x: &tensor[n, f32]) -> tensor[n, f32] = to_tensor(map(fn (v: f32) -> sigmoid(v), to_list(x)))
def tanh_vec[n](x: &tensor[n, f32]) -> tensor[n, f32] = to_tensor(map(fn (v: f32) -> tanh(v), to_list(x)))
def standardize[n](x: &tensor[n, f32], eps: f32) -> tensor[n, f32] = {
  xs = to_list(x)
  count = xs |> len |> cast(f32)
  total = fold(fn (acc: f32, v: f32) -> add(acc, v), 0.0f32, xs)
  mu = div(total, count)
  centered = map(fn (v: f32) -> sub(v, mu), to_list(x))
  sq_sum = fold(fn (acc: f32, v: f32) -> add(acc, mul(v, v)), 0.0f32, centered)
  variance = div(sq_sum, count)
  inv_std = 1.0f32 |> cast(f32) |> div(sqrt(add(variance, eps)))
  to_tensor(map(fn (v: f32) -> mul(v, inv_std), centered))
}
def rms_normalize[n](x: &tensor[n, f32], eps: f32) -> tensor[n, f32] = {
  xs = to_list(x)
  count = xs |> len |> cast(f32)
  sq_sum = fold(fn (acc: f32, v: f32) -> add(acc, mul(v, v)), 0.0f32, xs)
  scale = 1.0f32 |> cast(f32) |> div(sqrt(add(div(sq_sum, count), eps)))
  to_tensor(map(fn (v: f32) -> mul(v, scale), to_list(x)))
}
