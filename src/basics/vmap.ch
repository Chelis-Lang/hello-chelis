module Hello.Basics.Vmap
export (process, batch_process)
def process(x: &tensor[features, f32]) -> tensor[features, f32] = add(x, x)
def batch_process(xs: &tensor[batch, features, f32]) -> tensor[batch, features, f32] = vmap(process, axis=0)(xs)
