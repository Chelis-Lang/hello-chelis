# 05 — octant (LaTeX bridge)

Octant is a translator binary, not an importable Chelis library. Each
example here is a paired `.tex` (input) and `.ch` (verified output of
`octant translate`).

To regenerate the `.ch` files from the `.tex`:

```sh
for tex in examples/05_octant/*.tex; do
    octant translate "$tex" --output "${tex%.tex}.ch"
done
```

The harness in
[`tests/test_octant_pairs.py`](../../tests/test_octant_pairs.py) does this
on every CI run and asserts the regenerated `.ch` is byte-equivalent to
what's committed. Drift between the LaTeX and the Chelis is caught
immediately.

| Pair | Topic |
|---|---|
| [`basic_latex.{tex,ch}`](.) | `∫`, `∇`, `∂`, `∑` translated to typed Chelis |
| [`distributions_latex.{tex,ch}`](.) | `N(d_1)`, `Φ`, `φ` → `Nautilus.Distributions.Normal.*` |
| [`ad_through_latex.{tex,ch}`](.) | a function whose textbook form gets `grad`'d |
