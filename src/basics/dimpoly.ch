module Hello.Basics.DimPoly

export (identity_dim, scaled, double_apply)

-- A function that's polymorphic in its named dimension. The bracketed
-- `[a]` introduces a unification variable that gets resolved at each
-- call site.
def identity_dim[a](x: tensor[a, f32]) -> tensor[a, f32] = x

-- Same shape, scaled by 2 — using pipe + add to keep flow left-to-right.
def scaled[a](x: tensor[a, f32]) -> tensor[a, f32] =
  copy(x) |> add(x)

-- Two named-dim params unify independently. `f` is applied to a
-- `tensor[a, f32]`, demonstrating that dimension polymorphism composes.
def double_apply[a](f: tensor[a, f32] -> tensor[a, f32], x: tensor[a, f32]) -> tensor[a, f32] =
  x |> f |> f
