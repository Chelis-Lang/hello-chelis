def bad(x: tensor[n, f32]) -> tensor[n, f32] = {
  y = relu(x)
  add(x, y)
}
