module Hello.Basics.ModulesAndImports.Util

export (double, ones3)

-- Multiplied-by-two via `add`. Pipe form to demonstrate left-to-right flow.
def double(x: tensor[n, f32]) -> tensor[n, f32] =
  copy(x) |> add(x)

def ones3() -> tensor[n, f32] =
  to_tensor([cast(1.0, f32), cast(1.0, f32), cast(1.0, f32)])
