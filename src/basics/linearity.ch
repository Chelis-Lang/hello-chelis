module Hello.Basics.Linearity
export (double_shared, fan_out, copy_for_owner)
def double_shared[n](x: &tensor[n, f32]) -> tensor[n, f32] = add(x, x)
def fan_out[n](x: &tensor[n, f32]) -> tensor[n, f32] = add(x, add(x, x))
def take_owned[n](x: tensor[n, f32]) -> tensor[n, f32] = x
def copy_for_owner[n](x: &tensor[n, f32]) -> tensor[n, f32] = x |> copy |> take_owned
