-- chelis-expect-fail: UnboundVariable
def bad(x: tensor[n, f32]) -> tensor[n, f32] = missing(x)
