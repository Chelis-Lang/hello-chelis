module Hello.Std.TensorIo
import Std.Io (read_text, write_text, exists)
export (write_then_read, file_or_default, save_message)
def write_then_read(path: string, contents: string) -> string ! { IO } = {
  _ = write_text(path, contents)
  read_text(path)
}
def file_or_default(path: string, fallback: string) -> string ! { IO } = if exists(path) then read_text(path) else fallback
def save_message(path: string, message: string) -> string ! { IO } = {
  banner = string_concat("[hello] ", message)
  write_then_read(path, banner)
}
