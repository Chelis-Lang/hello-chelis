# `octant`

The LaTeX-to-Chelis bridge. **Octant is a translator binary, not an
importable Chelis library.** It turns a bounded subset of mathematical
LaTeX into typed Chelis Deep, with provenance back to byte ranges in the
source `.tex`.

Pinned to `0.4.4`. Installed in the Docker image and on `$PATH` as
`octant`. Reef pin in our [`reef.toml`](../../reef.toml) (the pin is
nominal — Octant doesn't ship Chelis modules to import).

## How you use it

```sh
# Translate a LaTeX file to Deep + provenance manifest
octant translate path/to/formula.tex \
    --output  path/to/formula.dp \
    --spans   path/to/formula.spans.json

# Type-check the LaTeX (cross-references % chelis: annotations)
octant check path/to/formula.tex

# Show what byte range a span ID covers
octant explain path/to/formula.tex --target n_001
```

## What translates

| LaTeX | Chelis target |
|---|---|
| `\int_a^b f(x)\, dx` | `Nautilus.Integrate.adaptive_simpson(f, a, b)` |
| `\nabla L` | `grad(L, wrt=θ)` |
| `\partial y / \partial x` | `grad(y, wrt=x)` |
| `N(d_1)` | `Nautilus.Distributions.Normal.cdf(d1)` |
| `\Phi`, `\phi` | `Nautilus.Distributions.Normal.cdf` / `pdf` |
| `\sum_i w_i x_i` | `sum(mul(w, x), 0)` |
| `\Gamma`, `\text{erf}`, `\sin`, `\log` | `Nautilus.Special.*` |

The shipped catalog lives at
[`src/functions.rs::shipped_builtins()`](https://github.com/Chelis-Lang/octant/blob/main/src/functions.rs)
upstream.

## Type annotations in LaTeX

Octant reads `% chelis: name : type` magic comments to seed type inference
for free-variable LaTeX. Without them, scope is ambiguous.

```latex
% chelis: x : f32
% chelis: a : f32
% chelis: b : f32
\int_a^b x\, dx
```

## Examples in this repo

See [`octant/`](../../octant/) — catalog at
[`octant/README.md`](../../octant/README.md). Each program is a
**quadruple**: `.tex` (LaTeX source) + `.dp` (canonical Deep emitted
by `octant translate`) + `.spans.json` (provenance manifest) + `.ch`
(best-effort Surf decompile via `chelis surf`). All four files are
committed; only the `.tex` is human-edited.

The harness at
[`tests/test_octant_pairs.py`](../../tests/test_octant_pairs.py)
re-runs the entire pipeline on every PR and asserts byte-equality
against the committed copies. Regenerate locally with
`python3 scripts/regen_octant.py`.
