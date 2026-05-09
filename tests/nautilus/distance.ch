module Hello.Tests.Nautilus.Distance
import Hello.Nautilus.Distance (euclid, manhattan_dist, chebyshev_dist, cosine_dist, self_distance_zero)
import Std.Test (assert_close)
def test_euclid_3_4_5() -> unit ! { Test } = {
  a = to_tensor([cast(0.0, f32), cast(0.0, f32)])
  b = to_tensor([cast(3.0, f32), cast(4.0, f32)])
  __borrow_migration_out_0 = assert_close(euclid(a, b), cast(5.0, f32), cast(0.000001, f32), "euclid 3-4-5")
  _ = drop(a)
  _ = drop(b)
  __borrow_migration_out_0
}
def test_manhattan_dist() -> unit ! { Test } = {
  a = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
  b = to_tensor([cast(4.0, f32), cast(6.0, f32), cast(3.0, f32)])
  __borrow_migration_out_1 = assert_close(manhattan_dist(a, b), cast(7.0, f32), cast(0.000001, f32), "L1 = 3+4+0 = 7")
  _ = drop(a)
  _ = drop(b)
  __borrow_migration_out_1
}
def test_chebyshev_dist() -> unit ! { Test } = {
  a = to_tensor([cast(0.0, f32), cast(0.0, f32), cast(0.0, f32)])
  b = to_tensor([cast(3.0, f32), cast(4.0, f32), cast(5.0, f32)])
  __borrow_migration_out_2 = assert_close(chebyshev_dist(a, b), cast(5.0, f32), cast(0.000001, f32), "Linf = max = 5")
  _ = drop(a)
  _ = drop(b)
  __borrow_migration_out_2
}
def test_cosine_parallel_zero() -> unit ! { Test } = {
  a = to_tensor([cast(1.0, f32), cast(2.0, f32)])
  b = to_tensor([cast(2.0, f32), cast(4.0, f32)])
  __borrow_migration_out_3 = assert_close(cosine_dist(a, b), cast(0.0, f32), cast(0.000001, f32), "cosine_dist parallel = 0")
  _ = drop(a)
  _ = drop(b)
  __borrow_migration_out_3
}
def test_self_distance_zero() -> unit ! { Test } = {
  v = to_tensor([cast(1.5, f32), cast(-2.0, f32), cast(3.25, f32)])
  __borrow_migration_out_4 = assert_close(self_distance_zero(v), cast(0.0, f32), cast(0.000001, f32), "d(x,x) = 0")
  _ = drop(v)
  __borrow_migration_out_4
}
