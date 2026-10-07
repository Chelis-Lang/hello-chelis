module Hello.Basics.ModulesAndImports.Util
export (double, ones3)
def double[n](x: &tensor[n, f32]) -> tensor[n, f32] = add(x, x)
def ones3() -> tensor[3, f32] = to_tensor([1.0f32, 1.0f32, 1.0f32])
