-- chelis-expect-fail: TypeMismatch
def take_owned(x: tensor[3, f32]) -> tensor[3, f32] = x
def invalid(x: &tensor[3, f32]) -> tensor[3, f32] = take_owned(x)
