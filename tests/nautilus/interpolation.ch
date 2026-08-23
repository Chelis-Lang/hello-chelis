module Hello.Tests.Nautilus.Interpolation
import Hello.Nautilus.Interpolation (linear_at_query, hermite_unit_segment, hermite_endpoint)
import Std.Test (assert_close)
def test_linear_at_node() -> unit ! { Test } = assert_close(linear_at_query(cast(1.0, f32)), cast(1.0, f32), cast(1e-6, f32), "linear interp at node = node value")
def test_linear_midpoint() -> unit ! { Test } = assert_close(linear_at_query(cast(1.5, f32)), cast(2.5, f32), cast(0.00001, f32), "linear interp midpoint of (1,1)-(2,4)")
def test_hermite_unit_midpoint() -> unit ! { Test } = assert_close(hermite_unit_segment(cast(0.5, f32)), cast(0.5, f32), cast(0.00001, f32), "Hermite cubic mid value = 0.5")
def test_hermite_endpoint() -> unit ! { Test } = assert_close(hermite_endpoint(), cast(7.0, f32), cast(0.00001, f32), "Hermite at right endpoint = y1")
