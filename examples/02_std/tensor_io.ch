module Hello.Std.TensorIo

import Std.Tensor.Construct (to_tensor)
import Std.Io (write_tensor_csv, read_tensor_csv)
import Std.Test (assert_close_tensor)

// Tensor I/O is effect-typed `! { IO }`. The effect propagates: anything
// that reads or writes a file declares IO, and any caller that doesn't
// declare IO triggers a checker error at the boundary.

def round_trip(path: string) -> tensor[n, f32] ! { IO } = {
  original = to_tensor([1.0, 2.0, 3.0, 5.0, 8.0])
  _ = write_tensor_csv(path, copy(original))
  read_tensor_csv(path)
}

def test_round_trip() -> unit ! { Test, IO } = {
  out = round_trip("/tmp/hello-chelis-tensor-io.csv")
  expected = to_tensor([1.0, 2.0, 3.0, 5.0, 8.0])
  assert_close_tensor(out, expected, 1e-6, "csv_roundtrip")
}
