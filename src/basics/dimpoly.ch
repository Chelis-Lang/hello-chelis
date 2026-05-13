module Hello.Basics.DimPoly
export (identity_dim, scaled, double_apply)
def identity_dim[a](x: &tensor[a, f32]) -> tensor[a, f32] = x
def scaled[a](x: &tensor[a, f32]) -> tensor[a, f32] = add(x, x)
def double_apply[a](f: &tensor[a, f32] -> tensor[a, f32], x: &tensor[a, f32]) -> tensor[a, f32] = x |> f |> f
