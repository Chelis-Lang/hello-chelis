module Hello.Coral.Io
import Coral.Frame (Frame, Column, from_pairs, nrows, ncols)
import Coral.Io (write_csv_frame, read_csv_frame)
export (sample_frame, roundtrip_csv)
def sample_frame() -> Frame[2] = { from_pairs([("price", FloatCol(to_tensor([cast(10.5, f32), cast(20.25, f32)]))), ("city", StringCol(["paris", "london"]))]) }
def roundtrip_csv(path: string) -> Frame[2] ! { IO } = {
  df = sample_frame()
  _ = write_csv_frame(df, path)
  read_csv_frame(path)
}
