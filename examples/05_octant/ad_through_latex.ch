module Hello.Octant.AdThroughLatex

import Std.Tensor.Construct (to_tensor)
import Std.Tensor.Reduce (sum)
import Std.Test (assert_close)

// Verified output of `octant translate ad_through_latex.tex`, plus a test
// that takes `grad` of the translated function. The point: the LaTeX is
// the source of truth; Chelis is the verified, differentiable form;
// `grad` works on the translated function the same as on any hand-written
// Chelis.

// span: ad_through_latex.tex#eq:half_x_sq_001
def f(x: tensor[f32]) -> tensor[f32] =
  mul(to_scalar(0.5), mul(x, copy(x)))

def to_scalar(v: f32) -> tensor[f32] = sum(to_tensor([v]), 0)

def test_f_at_3() -> unit ! { Test } =
  // f(3) = 9/2 = 4.5
  assert_close(f(to_scalar(3.0)), 4.5, 1e-6, "f_at_3")

def test_grad_f_at_3() -> unit ! { Test } =
  // f'(x) = x, so f'(3) = 3
  assert_close(grad(f)(to_scalar(3.0)), 3.0, 1e-6, "grad_f_at_3")
