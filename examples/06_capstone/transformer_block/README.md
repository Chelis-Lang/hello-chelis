# Capstone: Transformer block

The primer's transformer-block walkthrough as a runnable, tested example.
Single-headed for clarity; the multi-headed variant is one fan-out + one
concat away.

## Files

- [`block.ch`](block.ch) — the forward pass (attention + residual + LN +
  MLP + residual + LN), with explicit `copy(x)` at every fan-out.
- [`smoke.ch`](smoke.ch) — a smoke test: run the block on a small input,
  assert the output's shape, finiteness, and that `grad` produces a
  finite gradient at every weight.

## What this exercises

- **Linearity:** every fan-out (q/k/v from the same input, the residual
  branch, the MLP residual) shows up as a `copy(x)` call. Without these
  the program is rejected.
- **Named dimensions:** `seq` is symbolic (depends on input length); the
  internal dims (256, 64, 1024) are concrete sizes baked into the
  signature. Mismatches are compile errors before any tensor allocates.
- **`grad`:** the test asserts the backward pass over the entire block
  produces finite gradients at every parameter, demonstrating that
  Chelis's automatic-differentiation is structural (not bolted-on) and
  composes through layer_norm, softmax, matmul, and residuals.
