module Hello.Basics.MacroBasic

export (with_residual, doubled)

-- The std prelude ships a `residual(x, f)` macro that expands to
-- `add(x, f(x))` — the canonical skip-connection pattern, in macro
-- form so it's a one-liner at the call site.

-- A tiny "block" function we'll wrap with the residual macro.
def block(x: tensor[n, f32]) -> tensor[n, f32] =
  copy(x) |> add(x)

-- `residual(x, f)` is a prelude macro: residual(x, block) expands to
-- `add(x, block(x))`. The compiler type-checks the expansion the same
-- way as if you'd written it by hand.
def with_residual(x: tensor[n, f32]) -> tensor[n, f32] =
  residual(copy(x), block)

-- For comparison: same behavior, written without the macro.
def doubled(x: tensor[n, f32]) -> tensor[n, f32] =
  add(copy(x), block(x))
