module Hello.Coral.CsvJsonIo

import Std.Tensor.Construct (to_tensor)
import Coral.Frame (Frame, from_pairs, nrows, ncols, int_col_of_list)
import Coral.Io (read_csv_frame, write_csv_frame, read_json_frame, write_json_frame)
import Std.Test (assert_eq_int)

def small() -> Frame = {
  from_pairs([
    ("id",    int_col_of_list([cast(1, int64), cast(2, int64)])),
    ("price", FloatCol(to_tensor([cast(10.0, f32), cast(20.5, f32)]))),
    ("city",  StringCol(["london", "paris"]))
  ])
}

def csv_round_trip(path: string) -> Frame ! { IO } = {
  _ = write_csv_frame(small(), path)
  read_csv_frame(path)
}

def json_round_trip(path: string) -> Frame ! { IO } = {
  _ = write_json_frame(small(), path)
  read_json_frame(path)
}

def test_csv_round_trip_shape() -> unit ! { Test, IO } = {
  out = csv_round_trip("/tmp/hello-chelis-coral.csv")
  assert_eq_int(nrows(out), cast(2, int64), "csv_rows")
  assert_eq_int(ncols(out), cast(3, int64), "csv_cols")
}

def test_json_round_trip_shape() -> unit ! { Test, IO } = {
  out = json_round_trip("/tmp/hello-chelis-coral.json")
  assert_eq_int(nrows(out), cast(2, int64), "json_rows")
  assert_eq_int(ncols(out), cast(3, int64), "json_cols")
}

// Note: Parquet is upstream-blocked on v0.6.1 — `import Coral.Io.Parquet`
// resolves at check time but the runtime symbol is missing, so the link
// fails. No example for it here.
