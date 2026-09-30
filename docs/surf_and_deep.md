# Surf and Deep

Chelis has two syntaxes for the same AST. Programs under `src/`, `tests/`,
`tests_neg/`, and `verify/` ship in both, as paired files in the same
directory. Blocked probes under `tests_blocked/` pair Surf with an
expected-failure sidecar instead.

| Syntax | File | Audience | Role |
|---|---|---|---|
| Surf | `*.ch` | people | the readable, ML/Haskell-flavored syntax |
| Deep | `*.dp` | tools, models, the compiler | the canonical s-expression form of the AST |

## Why ship both

A normal Chelis project commits only `.ch`; its Deep form is derived on
demand with `chelis deep`. This repo commits both for the paired directories
above so that a reader can:

- see what the desugaring rules in
  [`spec/02-surf-syntax.md`](https://github.com/Chelis-Lang/chelis/blob/main/spec/02-surf-syntax.md)
  do to real programs. Every Surf construct used here (pipes, block
  bindings, infix arithmetic, dimension binders, transforms, patterns)
  appears in expanded form in the matching `.dp`;
- use the corpus as examples for tools or models that emit Deep rather than
  Surf. Each `.dp` is exactly what the compiler produces.

## How the pairs stay in sync

```sh
uv run scripts/regen_deep.py            # regenerate every .dp
uv run scripts/regen_deep.py --check    # report drift, change nothing
```

For every `.ch` under `src/`, `tests/`, `tests_neg/`, and `verify/`,
[`tests/test_surf_deep_equivalence.py`](../tests/test_surf_deep_equivalence.py)
runs `chelis deep` and requires the output to equal the committed `.dp` byte
for byte. Because each `.dp` is generated from its `.ch`, the two cannot
disagree about what the program means; CI fails if one is stale.

To type-check an example, check the `.ch`. `chelis check` treats a `.dp` as
a standalone program and does not load the package around it, so a sidecar
that imports names (for example `src/basics/effectsrandom.dp`, which
imports `normal_like`) reports them as unbound.

## Going back from Deep to Surf

`chelis surf <name>.dp` renders Deep back into Surf. The rendering is
readable but not identical to hand-written source, so the repo does not
require a round trip to reproduce the original `.ch`. The `.ch` files under
`octant/` are produced this way from the translator's Deep output.

## Worked example

Surf, [`src/basics/hellotensor.ch`](../src/basics/hellotensor.ch):

```chelis-surf
module Hello.Basics.HelloTensor
export (add_vec)
def add_vec[n](x: &tensor[n, f32], y: &tensor[n, f32]) -> tensor[n, f32] = add(x, y)
```

Deep, [`src/basics/hellotensor.dp`](../src/basics/hellotensor.dp), generated
by `chelis deep`:

```chelis-deep
(module {surf_path: "Hello.Basics.HelloTensor"}
  hello.basics.hellotensor
  (export {} add_vec)
  (defsig {}
    add_vec
    (n)
    (t-fn {}
      (t-ref {} (t-tensor {} (d-var {} n) (t-prim {} f32)))
      (t-ref {} (t-tensor {} (d-var {} n) (t-prim {} f32)))
      (t-tensor {} (d-var {} n) (t-prim {} f32))))
  (def {}
    add_vec
    (fn {}
      (params {} (x {type: (t-var {} _)}) (y {type: (t-var {} _)}))
      (app {span: "surf:124..133"}
        (var {span: "surf:124..127"} add)
        (var {span: "surf:128..129"} x)
        (var {span: "surf:131..132"} y)))))
```

Things to notice:

- Every node is `(tag {metadata} children...)`. The metadata map holds
  things like the original Surf module path and source spans.
- `def` with an inline signature becomes a `defsig` (the type, with the
  dimension binder `(n)`) plus a `def` (the body).
- `&tensor[...]` becomes `(t-ref {} (t-tensor ...))`, and `n` becomes a
  dimension variable `(d-var {} n)`.
- The `span` entries are byte ranges in the `.ch`, which is how diagnostics
  and generated C point back to the Surf source.
