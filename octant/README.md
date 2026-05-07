# Octant translations — LaTeX ↔ Deep ↔ Surf triples

[Octant](https://github.com/Chelis-Lang/octant) is the LaTeX-to-Chelis
bridge. It takes mathematical LaTeX and emits canonical Chelis Deep
plus a provenance manifest that maps every Deep node back to a byte
range in the source.

Each program here is committed in **three forms**:

| File | Surface | Author |
|---|---|---|
| `<name>.tex` | LaTeX | human |
| `<name>.dp` | canonical Deep | `octant translate <name>.tex` |
| `<name>.spans.json` | provenance | `octant translate` (alongside `.dp`) |
| `<name>.ch` | best-effort Surf decompile | `chelis surf <name>.dp` |

The .tex is the source of truth. Everything else is mechanically
derived. CI's [`tests/test_octant_pairs.py`](../tests/test_octant_pairs.py)
re-runs the pipeline on every PR and asserts byte-equality (modulo the
absolute-path field in `.spans.json`, which is sensitive to where
the test runs).

## Catalog

| Name | LaTeX shape | Why included |
|---|---|---|
| [`discount_factor`](discount_factor.tex) | `d = e^{-r t}` | simplest case: subscripts, superscripts, implicit multiplication |
| [`compound_interest`](compound_interest.tex) | `a = p (1 + r/n)^{n t}` | parenthesized sum, fraction, power |
| [`black_scholes_d1`](black_scholes_d1.tex) | `d_1 = (\ln(s/k) + (r + \sigma^2 / 2) t) / (\sigma \sqrt{t})` | `\frac`, `\ln`, Greek letters, `\sqrt` |
| [`normal_pdf`](normal_pdf.tex) | `y = \phi(x)` | named function from `Nautilus.Distributions` |

## Regenerating

After editing any `.tex`:

```sh
python3 scripts/regen_octant.py
```

Walks `octant/*.tex`, runs `octant translate` and `chelis surf`, and
overwrites the matching `.dp`, `.spans.json`, and `.ch`. Commit the
regenerated triples together with the source change.

## Why decompiled `.ch` files don't `chelis check` cleanly inside `src/`

The decompiled `.ch` is a fragment in Octant's bare style — bindings
without a surrounding `module Foo`, free variables typed via the
`% chelis: x : f32` magic comments in the LaTeX. That's why this
directory lives at the repo root rather than under `src/`: a Reef
project wants a fully-qualified `module` line per file.

Inside this directory the triple is self-consistent: round-trip
`tex -> dp -> ch` matches the committed copies.
