module Hello.Tests.Std.TensorIo
import Hello.Std.TensorIo (write_then_read, file_or_default, save_message)
import Std.Test (assert_eq)
def test_write_then_read() -> unit ! { Test, IO } = {
  result = write_then_read("/tmp/hello-chelis-tensorio-test.txt", "round-trip!")
  assert_eq(result, "round-trip!", "round-trip text I/O")
}
def test_file_or_default_missing() -> unit ! { Test, IO } = {
  fallback = file_or_default("/tmp/hello-chelis-does-not-exist.txt", "default")
  assert_eq(fallback, "default", "missing path -> fallback")
}
def test_save_message() -> unit ! { Test, IO } = {
  out = save_message("/tmp/hello-chelis-tensorio-msg.txt", "hi")
  assert_eq(out, "[hello] hi", "save_message persists banner")
}
