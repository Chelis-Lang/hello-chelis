# Capstone: Black-Scholes Greeks via `grad`

The European-call Black-Scholes price is

```
C(S, K, r, sigma, T) = S * N(d1) - K * exp(-r * T) * N(d2)
d1 = (ln(S/K) + (r + sigma^2 / 2) * T) / (sigma * sqrt(T))
d2 = d1 - sigma * sqrt(T)
```

`N` is the standard-normal CDF. The "Greeks" are partial derivatives of
`C` with respect to its inputs:

- delta = ∂C/∂S
- gamma = ∂²C/∂S²
- vega  = ∂C/∂σ
- rho   = ∂C/∂r
- theta = -∂C/∂T

Tonight's question: can we compute Greeks by `grad`'ing a textbook
Black-Scholes formula, and do they match the closed-form analytical
expressions plus a finite-difference cross-check?

## Files

- [`black_scholes.tex`](black_scholes.tex) — the textbook formula, with
  `% chelis:` magic comments naming the free variables.
- [`black_scholes.ch`](black_scholes.ch) — verified output of
  `octant translate black_scholes.tex`. The trust spine for the demo.
- [`greeks.ch`](greeks.ch) — `grad`-based Greeks, plus closed-form
  analytical expressions for cross-check, plus tests that compare both
  against finite differences.

## Why this matters

This is the cleanest demonstration of the Chelis trust stack at work:

1. The mathematics lives in LaTeX — readable, verifiable, the
   actual source of truth.
2. Octant translates it into typed Chelis Deep with span provenance.
3. `grad` computes Greeks directly from the translated formula, with no
   second hand-port to a pricing library and no risk of the two
   getting out of sync.
4. Closed-form analytical Greeks live next to the autodiff Greeks; tests
   assert they agree. Finite differences are a third corroboration.
5. The whole thing fits on one screen.
