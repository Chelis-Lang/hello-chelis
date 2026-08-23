module Hello.Nautilus.Optimize
import Nautilus.Optim (golden_section_search, brent_minimize, newton_minimize_1d)
export (parabola_minimum_gss, parabola_minimum_brent, parabola_minimum_newton)
def parabola(x: f32) -> f32 = {
  d = sub(x, cast(3.0, f32))
  add(mul(d, d), cast(7.0, f32))
}
def dparabola(x: f32) -> f32 = mul(cast(2.0, f32), sub(x, cast(3.0, f32)))
def ddparabola(x: f32) -> f32 = cast(2.0, f32)
def parabola_minimum_gss() -> f32 = golden_section_search(parabola, cast(0.0, f32), cast(10.0, f32), cast(1e-8, f32), cast(200, int64))
def parabola_minimum_brent() -> f32 = brent_minimize(parabola, cast(0.0, f32), cast(10.0, f32), cast(1e-8, f32), cast(200, int64))
def parabola_minimum_newton() -> f32 = newton_minimize_1d(parabola, dparabola, ddparabola, cast(0.0, f32), cast(1e-10, f32), cast(50, int64))
