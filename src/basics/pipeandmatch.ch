module Hello.Basics.PipeAndMatch

export (Activation, activate, pipeline)

-- ADTs declared with `type T = | A | B`. `match scrutinee with { ... }`
-- enforces exhaustivity at compile time — a missing arm is a type error.

type Activation =
  | Relu
  | Sigmoid

-- Pattern match across the two variants. The compiler verifies coverage.
def activate(act: Activation, x: tensor[n, f32]) -> tensor[n, f32] =
  match act with {
    | Relu    => relu(x)
    | Sigmoid => sigmoid(x)
  }

-- The pipe operator `|>` is the lowest-precedence binary operator.
-- `x |> relu |> sigmoid` reads left-to-right and is sugar for
-- `sigmoid(relu(x))`.
def pipeline(x: tensor[n, f32]) -> tensor[n, f32] =
  x |> relu |> sigmoid
