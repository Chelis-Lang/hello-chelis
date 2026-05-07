module Hello.Nautilus.Optimization1D

import Std.Tensor.Construct (to_tensor)
import Std.Tensor.Reduce (sum)
import Nautilus.Optimize (golden_section, brent_minimize)
import Std.Test (assert_close)

// f(x) = (x - 3)^2; minimum at x = 3, f(3) = 0.
def f(x: tensor[f32]) -> tensor[f32] = {
  d = add(x, neg(to_scalar(3.0)))
  mul(d, copy(d))
}

def to_scalar(v: f32) -> tensor[f32] = sum(to_tensor([v]), 0)

def test_golden_section() -> unit ! { Test } = {
  x = golden_section(f, cast(0.0, f32), cast(10.0, f32), cast(1e-6, f32), cast(100, int64))
  assert_close(x, 3.0, 1e-3, "golden_min_at_3")
}

def test_brent_minimize() -> unit ! { Test } = {
  x = brent_minimize(f, cast(0.0, f32), cast(10.0, f32), cast(1e-6, f32), cast(100, int64))
  assert_close(x, 3.0, 1e-3, "brent_min_at_3")
}
