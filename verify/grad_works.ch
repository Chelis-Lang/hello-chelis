module GradWorks

-- Demonstrates that `grad` actually lowers to C, links, and runs.
-- Builds with: chelis build verify/grad_works.ch --output /tmp/grad_works
-- Run:        /tmp/grad_works/grad_works
--
-- Pattern (per the compiler error message): make the function-to-
-- differentiate a parameter of the enclosing def, declare the local fn
-- explicitly, and call grad(local, wrt=(arg))(arg). This is what
-- crates/chelis-cli/tests/cli.rs::build_c_tensor_grad_local_wrapper_*
-- exercises in upstream's own test suite.

def loss_fn[n](w: tensor[n, f32], x: tensor[n, f32]) -> f32 = {
  one_vec = to_tensor([cast(1.0, f32), cast(1.0, f32), cast(1.0, f32)])
  err = sub(copy(w), one_vec)
  prod = mul(err, x)
  tensor_to_scalar(sum(prod, 0))
}

def dloss_dw[n](
  model: tensor[n, f32] -> tensor[n, f32] -> f32,
  w: tensor[n, f32],
  x: tensor[n, f32]
) -> tensor[n, f32] = {
  target = fn (w_local: tensor[n, f32]) -> model(w_local, x)
  grad(target, wrt=(w_local))(w)
}

-- d/dw [ sum((w - 1) * x) ] = x, evaluated at any w.
-- For x = [1, 2, 3] this prints [1.0, 2.0, 3.0].
w0 = to_tensor([cast(0.5, f32), cast(0.5, f32), cast(0.5, f32)])
x0 = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
dw = dloss_dw(loss_fn, w0, x0)
