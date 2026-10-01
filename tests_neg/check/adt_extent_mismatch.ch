-- chelis-expect-fail: DimensionMismatch
type Column[n] =
  | FloatCol(tensor[n, f32])
def right() -> Column[3] = FloatCol(to_tensor([1.0f32, 2.0f32]))
