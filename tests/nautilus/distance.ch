module Hello.Tests.Nautilus.Distance
import Hello.Nautilus.Distance (euclid, manhattan_dist, chebyshev_dist, cosine_dist, self_distance_zero)
import Std.Test (assert_close)
def test_euclid_3_4_5() -> unit ! { Test } = {
  a = to_tensor([0.0f32, 0.0f32])
  b = to_tensor([3.0f32, 4.0f32])
  assert_close(euclid(a, b), 5.0f32, 1e-6f32, "euclid 3-4-5")
}
def test_manhattan_dist() -> unit ! { Test } = {
  a = to_tensor([1.0f32, 2.0f32, 3.0f32])
  b = to_tensor([4.0f32, 6.0f32, 3.0f32])
  assert_close(manhattan_dist(a, b), 7.0f32, 1e-6f32, "L1 = 3+4+0 = 7")
}
def test_chebyshev_dist() -> unit ! { Test } = {
  a = to_tensor([0.0f32, 0.0f32, 0.0f32])
  b = to_tensor([3.0f32, 4.0f32, 5.0f32])
  assert_close(chebyshev_dist(a, b), 5.0f32, 1e-6f32, "Linf = max = 5")
}
def test_cosine_parallel_zero() -> unit ! { Test } = {
  a = to_tensor([1.0f32, 2.0f32])
  b = to_tensor([2.0f32, 4.0f32])
  assert_close(cosine_dist(a, b), 0.0f32, 1e-6f32, "cosine_dist parallel = 0")
}
def test_self_distance_zero() -> unit ! { Test } = {
  v = to_tensor([1.5f32, -2.0f32, 3.25f32])
  assert_close(self_distance_zero(v), 0.0f32, 1e-6f32, "d(x,x) = 0")
}
