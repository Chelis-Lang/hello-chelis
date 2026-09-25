-- chelis-expect-fail: DimensionMismatch
type Column[n] =
  | FloatCol(tensor[n, f32])
def right() -> Column[3] = FloatCol(to_tensor([cast(1.0, f32), cast(2.0, f32)]))
