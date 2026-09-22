module Hello.Basics.JitRealize
export (eager, with_realize)
def eager[n](w: &tensor[n, f32], x: &tensor[n, f32]) -> tensor[n, f32] = mul(w, x)
def with_realize[n](x: &tensor[n, f32]) -> tensor[n, f32] = {
  doubled = x |> add(x) |> realize
  add(doubled, x)
}
