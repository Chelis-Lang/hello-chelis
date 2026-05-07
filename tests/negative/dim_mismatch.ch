// chelis-expect-fail: DimensionMismatch
//
// `batch` and `seq` are nominally distinct dimensions even if their
// runtime sizes happen to match. `add` requires identical dim lists.

module Hello.Negative.DimMismatch

def bad(x: tensor[batch, f32], y: tensor[seq, f32]) -> tensor[batch, f32] =
  add(x, y)
