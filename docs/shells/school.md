# `school`

The neural-network library. Holds the `Nn.*` and `Loss.*` modules that
shipped inside `chelis-std` before 0.4.0 moved them out into their own
package.

Pinned to `0.1.13`. Reef declaration in our [`reef.toml`](../../reef.toml)
under `[dependencies]`.

## Why it exists

As of `chelis-std` 0.4.0 the standard library no longer carries the
neural-network and loss surfaces. They live in `school` instead, so a
program that used to import `Std.Nn.Silu` / `Std.Loss.CrossEntropy` now
imports `School.Nn.Silu` / `School.Loss.CrossEntropy`. The module names
are otherwise unchanged: the migration is a one-for-one `Std.*` ->
`School.*` prefix swap.

## What this repo uses

| School module | Names | Used by |
|---|---|---|
| `School.Nn.Silu` | `sigmoid_scalar` | [`src/std/activationsnorms.ch`](../../src/std/activationsnorms.ch) |
| `School.Nn.Gelu` | `gelu_scalar`, `tanh_scalar` | [`src/std/activationsnorms.ch`](../../src/std/activationsnorms.ch) |
| `School.Nn.RmsNorm` | `rms_scale` | [`src/std/activationsnorms.ch`](../../src/std/activationsnorms.ch) |
| `School.Loss.CrossEntropy` | `loss` | [`src/std/reductionslosses.ch`](../../src/std/reductionslosses.ch) |
| `School.Loss.Bce` | `bce_with_logits` | [`src/std/reductionslosses.ch`](../../src/std/reductionslosses.ch) |
| `School.Loss.KlDiv` | `kl_divergence` | [`src/std/reductionslosses.ch`](../../src/std/reductionslosses.ch) |
| `School.Loss.Metrics` | `perplexity` | [`src/std/reductionslosses.ch`](../../src/std/reductionslosses.ch) |

`school` ships a much larger surface (optimizers, attention, conv,
embeddings, full reference models); this corpus exercises only the
activation/normalization and loss slices that the std tour used before
the move.

## Borrow-form note

Some school signatures differ from the old `chelis-std` ones in
ownership. `School.Loss.CrossEntropy.loss` and
`School.Loss.KlDiv.kl_divergence` take owned tensors, whereas the
matching std functions took `&`-borrows; `School.Loss.Bce.bce_with_logits`
keeps the borrowed form. The wrappers in `src/std/reductionslosses.ch`
match each school signature exactly.
