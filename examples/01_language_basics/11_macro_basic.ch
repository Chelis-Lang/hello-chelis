module Hello.Basics.MacroBasic

import Std.Tensor.Construct (to_tensor)
import Std.Test (assert_close_tensor)

// Macros operate on Deep AST nodes at compile time. They're declared with
// the `macro` keyword and produce typed Deep that goes through the same
// type checker as hand-written code — there's no second trust stack.
//
// This macro `apply_n_times` takes a function `f` and an integer `n`, and
// expands to `f(f(...f(x)...))` n times. Useful for common patterns like
// "apply this normalization layer K times" without writing K calls by
// hand.

macro apply_n_times(f, n, x) = {
  // The macro body returns a Deep expression. `quote` lifts a Surf
  // expression into Deep; `unquote` splices a value back in.
  if n == 0 then
    quote(unquote(x))
  else
    quote(unquote(f)(unquote(apply_n_times(f, n - 1, x))))
}

def step(y: tensor[n, f32]) -> tensor[n, f32] =
  add(y, to_tensor([1.0, 1.0, 1.0]))

// `apply_n_times(step, 3, x)` expands to `step(step(step(x)))` at compile
// time. The expanded form is type-checked normally.
def add_three(x: tensor[n, f32]) -> tensor[n, f32] =
  apply_n_times(step, 3, x)

def test_add_three() -> unit ! { Test } = {
  x = to_tensor([0.0, 10.0, 100.0])
  out = add_three(x)
  expected = to_tensor([3.0, 13.0, 103.0])
  assert_close_tensor(out, expected, 1e-6, "apply_n_times_3")
}
