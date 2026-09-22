module Hello.Basics.Linearity
export (double_shared, fan_out)
def double_shared[n](x: &tensor[n, f32]) -> tensor[n, f32] = add(x, x)
def fan_out[n](x: &tensor[n, f32]) -> tensor[n, f32] = add(x, add(x, x))
