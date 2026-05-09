module Hello.Basics.MacroBasic
export (with_residual, doubled)
def block(x: &tensor[n, f32]) -> tensor[n, f32] = add(x, x)
def with_residual(x: &tensor[n, f32]) -> tensor[n, f32] = residual(copy(x), block)
def doubled(x: &tensor[n, f32]) -> tensor[n, f32] = add(x, block(x))
