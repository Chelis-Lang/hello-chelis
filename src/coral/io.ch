module Hello.Coral.Io
import Coral.Frame (Frame, Column, FloatCol, StringCol, from_pairs, nrows, ncols)
import Coral.Io (write_csv_frame, read_csv_frame)
export (sample_frame, roundtrip_csv)
def sample_frame() -> Frame[2] = from_pairs([("price", FloatCol(to_tensor([10.5f32, 20.25f32]))), ("city", StringCol(["paris", "london"]))])
def roundtrip_csv(path: string) -> Frame[2] ! { IO } = {
  df = sample_frame()
  _ = write_csv_frame(df, path)
  read_csv_frame(path)
}
