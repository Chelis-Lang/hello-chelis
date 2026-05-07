module Hello.Basics.Mods.Util

import Std.Tensor.Construct (to_tensor)

export (double, halve, ones3)

def double(x: tensor[n, f32]) -> tensor[n, f32] = add(x, x)
def halve(x: tensor[n, f32]) -> tensor[n, f32] = mul(x, ones_like_half(x))

// helper, not exported
def ones_like_half(x: tensor[n, f32]) -> tensor[n, f32] =
  to_tensor([0.5, 0.5, 0.5])

def ones3() -> tensor[n, f32] = to_tensor([1.0, 1.0, 1.0])
