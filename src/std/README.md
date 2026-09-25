# `src/std/`: the standard library

A tour of `chelis-std` (bundled with the compiler) and of the neural-network
and loss modules from the [`school`](https://github.com/Chelis-Lang/school)
package.

| File | Uses | What it shows |
|---|---|---|
| [`activationsnorms.ch`](activationsnorms.ch) | tensor builtins, `School.Nn.*` | tensor `relu` / `sigmoid`; GELU, SiLU, and tanh via School's scalar functions; RMS norm; a hand-written layer norm |
| [`reductionslosses.ch`](reductionslosses.ch) | tensor reductions, `School.Loss.*` | sum / mean / product along an axis; cross-entropy, BCE with logits, KL divergence, perplexity |
| [`decimal.ch`](decimal.ch) | `Std.Decimal` | exact decimal arithmetic for prices and tax |
| [`datetimecal.ch`](datetimecal.ch) | `Std.Time` | dates, day arithmetic, weekday names, formatting |
| [`collectionsiter.ch`](collectionsiter.ch) | `List`, `Dict`, iteration | `map` / `filter` / `fold` / `scan`, a vocabulary dictionary |
| [`tensorio.ch`](tensorio.ch) | `Std.Io` | text file I/O, with `! { IO }` on every function that touches the filesystem |

Each file has a test of the same name under [`tests/std/`](../../tests/std/).

For the full API, see the `chelis-std` reference,
[`packages/chelis-std/SKILL.md`](https://github.com/Chelis-Lang/chelis/blob/main/packages/chelis-std/SKILL.md),
and the [`school` documentation](https://github.com/Chelis-Lang/school).
