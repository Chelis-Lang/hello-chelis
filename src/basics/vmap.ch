module Hello.Basics.Vmap

export (process, batch_process)

-- A per-example function. Operates on a single feature vector.
def process(x: tensor[features, f32]) -> tensor[features, f32] =
  copy(x) |> add(x)  -- doubled

-- `vmap` lifts the per-example function over a batch axis. The compiler
-- adds an extra axis to every type in scope, so calling `vmap(f, 0)`
-- on `tensor[batch, features, f32]` produces another
-- `tensor[batch, features, f32]`.
def batch_process(xs: tensor[batch, features, f32]) -> tensor[batch, features, f32] =
  xs |> vmap(process, 0)
