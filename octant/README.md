# `octant/`: LaTeX to Chelis

[Octant](https://github.com/Chelis-Lang/octant) translates a bounded subset
of mathematical LaTeX into Chelis Deep, with a provenance map that ties each
Deep node back to a byte range in the LaTeX. It is a command-line tool, not a
library you import, which is why these files live here rather than under
`src/`.

Each example is committed in four files:

| File | Contents | Produced by |
|---|---|---|
| `<name>.tex` | the formula | written by hand |
| `<name>.dp` | canonical Deep | `octant translate` |
| `<name>.spans.json` | provenance: Deep node to LaTeX byte range | `octant translate` |
| `<name>.ch` | the Deep rendered as Surf | `chelis surf <name>.dp` |

Only the `.tex` is edited by hand. [`tests/test_octant_pairs.py`](../tests/test_octant_pairs.py)
reruns the pipeline and requires all three outputs to match the committed
files byte for byte.

## Catalog

| Name | LaTeX | Why it is here |
|---|---|---|
| [`discount_factor`](discount_factor.tex) | `d = e^{-r t}` | subscripts, superscripts, implicit multiplication |
| [`compound_interest`](compound_interest.tex) | `a = p (1 + r/n)^{n t}` | parentheses, a fraction, a power |
| [`black_scholes_d1`](black_scholes_d1.tex) | `d_1 = (\ln(s/k) + (r + \sigma^2 / 2) t) / (\sigma \sqrt{t})` | `\frac`, `\ln`, Greek letters, `\sqrt`; the same `d_1` as [`src/capstone/blackscholes.ch`](../src/capstone/blackscholes.ch) |
| [`normal_pdf`](normal_pdf.tex) | `y = \phi(x)` | a named function mapped to `Nautilus.Distributions`; the Deep carries a placeholder `normal_pdf` definition standing in for the Nautilus function |

## Using the translator

```sh
octant translate octant/discount_factor.tex \
    --output octant/discount_factor.dp \
    --spans  octant/discount_factor.spans.json
octant check   octant/discount_factor.tex        # parse and type-infer only
octant explain octant/discount_factor.tex --target <deep-node-id>
```

Free variables get their types from `% chelis: name : type` comments in the
LaTeX; open any `.tex` here for an example. The subset Octant accepts is
documented in the [Octant repository](https://github.com/Chelis-Lang/octant).

To regenerate everything after editing a `.tex`:

```sh
uv run scripts/regen_octant.py
```

## Why the `.ch` files are fragments

The `.ch` files are Octant's bindings rendered as Surf, without a
`module Hello.*` header, so they are not modules of this package. They exist
to show what the translated Deep means, not to be imported.
