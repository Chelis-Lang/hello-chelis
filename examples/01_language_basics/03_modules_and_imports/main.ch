module Hello.Basics.Mods.Main

// Form 1: glob — pull everything exported into unqualified scope.
import Hello.Basics.Mods.Util (..)

// Form 2: selective — pull named items only.
import Std.Tensor.Construct (to_tensor)

// Form 3: qualified-only — must use Std.Tensor.Reduce.sum below.
import Std.Tensor.Reduce

import Std.Test (assert_close, assert_close_tensor)

def main() -> tensor[f32] = {
  x = ones3()                         // unqualified, via Form 1
  y = double(x)                       // unqualified, via Form 1
  z = to_tensor([10.0, 20.0, 30.0])   // unqualified, via Form 2
  w = add(y, z)
  Std.Tensor.Reduce.sum(w, 0)         // qualified, via Form 3
}

def test_main_sum() -> unit ! { Test } = {
  out = main()
  // ones3() = [1, 1, 1]; double = [2, 2, 2]; +z = [12, 22, 32]; sum = 66
  assert_close(out, 66.0, 1e-6, "mods_main_sum")
}

def test_halve() -> unit ! { Test } = {
  in_ = to_tensor([4.0, 8.0, 12.0])
  out = halve(in_)
  expected = to_tensor([2.0, 4.0, 6.0])
  assert_close_tensor(out, expected, 1e-6, "halve")
}
