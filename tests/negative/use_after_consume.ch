// chelis-expect-fail: UseAfterConsume
//
// `x` is consumed by `relu(x)` on the second line, then referenced again
// in `add(x, y)`. The compiler must reject this with the canonical
// `UseAfterConsume` diagnostic and a hint to insert `copy(x)`.

module Hello.Negative.UseAfterConsume

import Std.Tensor.Construct (to_tensor)

def bad(x: tensor[n, f32]) -> tensor[n, f32] = {
  y = relu(x)
  add(x, y)
}
