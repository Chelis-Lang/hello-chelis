module Hello.Basics.HelloTensor
export (add_vec)
def add_vec(x: &tensor[n, f32], y: &tensor[n, f32]) -> tensor[n, f32] = add(x, y)
