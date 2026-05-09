module Hello.Basics.Linearity
export (residual, fan_out)
def residual(x: &tensor[n, f32]) -> tensor[n, f32] = add(x, x)
def fan_out(x: &tensor[n, f32]) -> tensor[n, f32] = add(x, add(x, x))
