-- chelis-expect-fail: DimensionMismatch
def bad(x: tensor[batch, f32], y: tensor[seq, f32]) -> tensor[batch, f32] = add(x, y)
