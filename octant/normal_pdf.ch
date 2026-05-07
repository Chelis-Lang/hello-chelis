-- Standard normal density: y = phi(x).
-- Hand-written reference paired with normal_pdf.tex.

import Nautilus.Special (normal_pdf)

def y(x: f32) -> f32 = normal_pdf(x)
