-- Compound interest: a = p * (1 + r/n)^(n*t).
-- Hand-written reference paired with compound_interest.tex.
--
-- The general-exponent power lowering is exp(log(base) * exp), per
-- spec §4.6's pow lowering table.

def a(p: f32, r: f32, n: f32, t: f32) -> f32 =
  mul(p, exp(mul(log(add(1, div(r, n))), mul(n, t))))
