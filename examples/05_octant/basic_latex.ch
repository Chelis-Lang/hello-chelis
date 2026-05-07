module Hello.Octant.BasicLatex

// This file is the verified output of:
//   octant translate examples/05_octant/basic_latex.tex
// Do not hand-edit. Re-run the translator if the .tex changes; the CI
// harness in tests/test_octant_pairs.py asserts the regenerated form is
// byte-equivalent to this committed copy.

import Nautilus.Integrate (adaptive_simpson)
import Std.Tensor.Construct (to_tensor)
import Std.Tensor.Reduce (sum)

// span: examples/05_octant/basic_latex.tex#eq:integral_001
def integral_a_to_b(a: f32, b: f32) -> f32 =
  adaptive_simpson(fn (x: tensor[f32]) -> x, a, b, cast(1e-6, f32), cast(20, int64))

// span: examples/05_octant/basic_latex.tex#eq:grad_001
def grad_L(L: tensor[f32]) -> tensor[n, f32] =
  // \nabla L resolves to grad over the implicit `theta` once L is wrapped.
  // The bare \nabla L gets translated to a placeholder until the customer
  // provides a target parameter via `% chelis: theta : ...`.
  to_tensor([0.0])

// span: examples/05_octant/basic_latex.tex#eq:partial_001
def partial_y_x(y: tensor[f32], x: tensor[f32]) -> tensor[f32] =
  // \partial y / \partial x with x scalar.
  grad(fn (x: tensor[f32]) -> y)(x)

// span: examples/05_octant/basic_latex.tex#eq:innerprod_001
def inner_product(w: tensor[n, f32], xs: tensor[n, f32]) -> tensor[f32] =
  sum(mul(w, xs), 0)
