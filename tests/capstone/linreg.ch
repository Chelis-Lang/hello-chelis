module Hello.Tests.Capstone.LinReg
import Hello.Capstone.LinReg (predict)
import Std.Test (assert_close)
def vector_64(value: f32) -> tensor[64, f32] = expand(sum(to_tensor([value]), 0), 0, 64)
def matrix_64_64(value: f32) -> tensor[64, 64, f32] = expand(vector_64(value), 0, 64)
def matrix_64_1(value: f32) -> tensor[64, 1, f32] = expand(to_tensor([value]), 0, 64)
def test_predict_bias_shape_and_value() -> unit ! { Test } = {
  x = matrix_64_64(cast(1.0, f32))
  w = matrix_64_1(cast(1.0, f32))
  b = to_tensor([cast(1.0, f32)])
  total = tensor_to_scalar(sum(sum(predict(x, w, b), 1), 0))
  assert_close(total, cast(4160.0, f32), cast(0.000001, f32), "predict_bias")
}
