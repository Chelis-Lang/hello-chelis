module Hello.Basics.ModulesAndImports.Util
export (double, ones3)
def double[n](x: &tensor[n, f32]) -> tensor[n, f32] = add(x, x)
def ones3() -> tensor[3, f32] = to_tensor([cast(1.0, f32), cast(1.0, f32), cast(1.0, f32)])
