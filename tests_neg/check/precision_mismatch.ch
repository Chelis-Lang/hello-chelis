-- chelis-expect-fail: PrecisionMismatch
def bad[n](x: tensor[n, f32], y: tensor[n, f64]) -> tensor[n, f32] = add(x, y)
