module Hello.Basics.JitRealize
export (eager, with_realize)
def eager(w: &tensor[n, f32], x: &tensor[n, f32]) -> tensor[n, f32] = mul(w, x)
def with_realize(x: &tensor[n, f32]) -> tensor[n, f32] = {
  doubled = realize(add(x, x))
  __borrow_migration_out_0 = add(doubled, x)
  __borrow_migration_out_0
}
