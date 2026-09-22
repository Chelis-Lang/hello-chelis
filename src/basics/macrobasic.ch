module Hello.Basics.MacroBasic
export (block, with_residual, doubled)
def block[n](x: &tensor[n, f32]) -> tensor[n, f32] = add(x, x)
def with_residual[n](x: &tensor[n, f32]) -> tensor[n, f32] = residual(x, block)
def doubled[n](x: &tensor[n, f32]) -> tensor[n, f32] = add(x, block(x))
