module Hello.Nautilus.Optimize
import Nautilus.Optim (golden_section_search, brent_minimize, newton_minimize_1d)
export (parabola, parabola_minimum_gss, parabola_minimum_brent, parabola_minimum_newton)
def parabola(x: f32) -> f32 = {
  d = sub(x, 3.0f32)
  add(mul(d, d), 7.0f32)
}
@property parabola_global_minimum forall(x: f32):
  (parabola(x) >= 7.0f32)
@property parabola_box_lower forall(x: f32) where x >= 3.1f32, x <= 3.9f32:
  (parabola(x) >= 7.0f32)
@property parabola_box_upper forall(x: f32) where x >= 3.1f32, x <= 3.9f32:
  (parabola(x) <= 8.0f32)
def dparabola(x: f32) -> f32 = mul(2.0f32, sub(x, 3.0f32))
def ddparabola(x: f32) -> f32 = 2.0f32
def parabola_minimum_gss() -> f32 = golden_section_search(parabola, 0.0f32, 10.0f32, 1e-8f32, 200i64)
def parabola_minimum_brent() -> f32 = brent_minimize(parabola, 0.0f32, 10.0f32, 1e-8f32, 200i64)
def parabola_minimum_newton() -> f32 = newton_minimize_1d(parabola, dparabola, ddparabola, 0.0f32, 1e-10f32, 50i64)
