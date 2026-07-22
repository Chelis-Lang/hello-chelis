module Hello.TestsBlocked.Coral.Parquet
import Coral.Frame (nrows)
import Coral.Io (read_parquet_frame)
import Std.Test (assert_eq_int)
def test_parquet_runtime() -> unit ! { Test } = assert_eq_int(nrows(read_parquet_frame("missing.parquet")), cast(0, int64), "parquet runtime")
