module Hello.Tests.Std.Elementwise
import Hello.Std.Elementwise (logistic_vec, tanh_vec, standardize, rms_normalize)
import Std.Test (assert_close)
def test_sigmoid_scalar_zero() -> unit ! { Test } = {
  result = sigmoid(cast(0.0, f32))
  assert_close(result, cast(0.5, f32), cast(1e-6, f32), "sigmoid(0)=0.5")
}
def test_tanh_scalar_zero() -> unit ! { Test } = {
  result = tanh(cast(0.0, f32))
  assert_close(result, cast(0.0, f32), cast(1e-6, f32), "tanh(0)=0")
}
def test_logistic_vec_symmetric() -> unit ! { Test } = {
  out = to_list(logistic_vec(to_tensor([cast(-2.0, f32), cast(2.0, f32)])))
  total = add(index(out, cast(0, i64)), index(out, cast(1, i64)))
  assert_close(total, cast(1.0, f32), cast(1e-6, f32), "sigmoid(-x)+sigmoid(x)=1")
}
def test_tanh_vec_odd() -> unit ! { Test } = {
  out = to_list(tanh_vec(to_tensor([cast(-0.5, f32), cast(0.5, f32)])))
  total = add(index(out, cast(0, i64)), index(out, cast(1, i64)))
  assert_close(total, cast(0.0, f32), cast(1e-6, f32), "tanh(-x)+tanh(x)=0")
}
def test_standardize_zero_mean() -> unit ! { Test } = {
  x = to_tensor([cast(-1.0, f32), cast(0.0, f32), cast(1.0, f32)])
  normed = standardize(x, cast(1e-6, f32))
  total = fold(fn (acc: f32, v: f32) -> add(acc, v), cast(0.0, f32), to_list(normed))
  assert_close(total, cast(0.0, f32), cast(0.0001, f32), "standardize has zero mean")
}
def test_rms_normalize_unit_rms() -> unit ! { Test } = {
  x = to_tensor([cast(3.0, f32), cast(4.0, f32)])
  normed = rms_normalize(x, cast(0.0, f32))
  sq_sum = fold(fn (acc: f32, v: f32) -> add(acc, mul(v, v)), cast(0.0, f32), to_list(normed))
  assert_close(sq_sum, cast(2.0, f32), cast(0.0001, f32), "rms_normalize gives unit rms")
}
