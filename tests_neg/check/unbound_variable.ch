-- chelis-expect-fail: UnboundVariable
def bad[n](x: tensor[n, f32]) -> tensor[n, f32] = missing(x)
