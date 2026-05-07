module Hello.Std.TensorIo

import Std.Io (read_text, write_text, exists)

export (write_then_read, file_or_default, save_message)

-- Note: `Std.Io` in chelis-std v0.2.0 is text-only — it does not yet
-- ship tensor I/O. We demonstrate the text round-trip and the IO
-- effect propagation that any caller would inherit.

-- Write `contents` to `path`, then read it back. The IO effect is
-- inferred from `read_text`/`write_text`.
def write_then_read(path: string, contents: string) -> string ! { IO } = {
  _ = write_text(path, contents);
  read_text(path)
}

-- If the file exists, return its contents; otherwise return the
-- supplied default. Useful for config-style lookups.
def file_or_default(path: string, fallback: string) -> string ! { IO } = {
  if exists(path) then read_text(path) else fallback
}

-- Persist a message under a fixed path and return the round-tripped
-- string for verification.
def save_message(path: string, message: string) -> string ! { IO } = {
  banner = string_concat("[hello] ", message)
  write_then_read(path, banner)
}
