module Hello.Tests.Std.Elementwise
import Hello.Std.Elementwise (logistic_vec, tanh_vec, standardize, rms_normalize)
import Std.Test (assert_close)
def test_sigmoid_scalar_zero() -> unit ! { Test } = {
  result = sigmoid(0.0f32)
  assert_close(result, 0.5f32, 1e-6f32, "sigmoid(0)=0.5")
}
def test_tanh_scalar_zero() -> unit ! { Test } = {
  result = tanh(0.0f32)
  assert_close(result, 0.0f32, 1e-6f32, "tanh(0)=0")
}
def test_logistic_vec_symmetric() -> unit ! { Test } = {
  out = to_list(logistic_vec(to_tensor([-2.0f32, 2.0f32])))
  total = add(index(out, 0i64), index(out, 1i64))
  assert_close(total, 1.0f32, 1e-6f32, "sigmoid(-x)+sigmoid(x)=1")
}
def test_tanh_vec_odd() -> unit ! { Test } = {
  out = to_list(tanh_vec(to_tensor([-0.5f32, 0.5f32])))
  total = add(index(out, 0i64), index(out, 1i64))
  assert_close(total, 0.0f32, 1e-6f32, "tanh(-x)+tanh(x)=0")
}
def test_standardize_zero_mean() -> unit ! { Test } = {
  x = to_tensor([-1.0f32, 0.0f32, 1.0f32])
  normed = standardize(x, 1e-6f32)
  total = fold(fn (acc: f32, v: f32) -> add(acc, v), 0.0f32, to_list(normed))
  assert_close(total, 0.0f32, 0.0001f32, "standardize has zero mean")
}
def test_rms_normalize_unit_rms() -> unit ! { Test } = {
  x = to_tensor([3.0f32, 4.0f32])
  normed = rms_normalize(x, 0.0f32)
  sq_sum = fold(fn (acc: f32, v: f32) -> add(acc, mul(v, v)), 0.0f32, to_list(normed))
  assert_close(sq_sum, 2.0f32, 0.0001f32, "rms_normalize gives unit rms")
}
