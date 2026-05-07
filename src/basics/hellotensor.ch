module Hello.Basics.HelloTensor

export (add_vec)

-- Element-wise add over a vector of length `n`.
--
-- `n` is a named dimension. `add(x, y)` requires both operands to share the
-- same named-dim list and the same precision. There is no implicit
-- broadcasting: `tensor[n, f32]` and `tensor[m, f32]` do not unify.
def add_vec(x: tensor[n, f32], y: tensor[n, f32]) -> tensor[n, f32] =
  add(x, y)
