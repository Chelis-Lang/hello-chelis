module Hello.Tests.Basics.GradBasic

import Hello.Basics.GradBasic (loss)
import Std.Test (assert_close)

-- The IR evaluator (`chelis test`) doesn't yet implement runtime
-- lowering for `grad`; it does for the underlying loss function.
-- `chelis check` validates the grad demonstrations in
-- src/basics/gradbasic.ch.
--
-- Here we just exercise the loss directly: at w=[2,2,2], x=[1,1,1]:
-- err = w-1 = [1,1,1]; loss = sum(err*x) = 3.
-- (loss returns a rank-0 tensor; we extract the scalar via sum-of-1.)

def test_loss_via_pipe() -> unit ! { Test } = {
  w = to_tensor([cast(2.0, f32), cast(2.0, f32), cast(2.0, f32)])
  x = to_tensor([cast(1.0, f32), cast(1.0, f32), cast(1.0, f32)])
  -- chain reduce to f32: tensor[f32] -> f32 via to_list + index
  v = loss(w, x)
  reduced = sum(to_tensor([cast(0.0, f32)]) |> add(expand(v, 0, 1)), 0)
  assert_close(reduced, cast(3.0, f32), cast(1e-5, f32), "loss_at_w2")
}
