module Hello.Nautilus.DistanceMetrics

import Std.Tensor.Construct (to_tensor)
import Nautilus.Distance (euclidean, manhattan, chebyshev, cosine)
import Std.Test (assert_close)

def a() -> tensor[n, f32] = to_tensor([1.0, 2.0, 3.0])
def b() -> tensor[n, f32] = to_tensor([4.0, 6.0, 3.0])

// dx = [3, 4, 0]; |dx| = sqrt(25) = 5
def test_euclidean() -> unit ! { Test } =
  assert_close(euclidean(a(), b()), 5.0, 1e-6, "euclidean_345")

// |3| + |4| + |0| = 7
def test_manhattan() -> unit ! { Test } =
  assert_close(manhattan(a(), b()), 7.0, 1e-6, "manhattan_345")

// max(|3|, |4|, |0|) = 4
def test_chebyshev() -> unit ! { Test } =
  assert_close(chebyshev(a(), b()), 4.0, 1e-6, "chebyshev_345")

// cosine of vec to itself is 0
def test_cosine_self_zero() -> unit ! { Test } = {
  x = to_tensor([1.0, 2.0, 3.0])
  y = copy(x)
  assert_close(cosine(x, y), 0.0, 1e-6, "cosine_self")
}
