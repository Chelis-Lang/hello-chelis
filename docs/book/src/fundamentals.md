# Surf and Deep

The `.ch` files in the lessons use Surf, Chelis's readable source syntax.
The compiler can render their structure as Deep, an s-expression syntax
with nested parentheses and tagged nodes. Deep files use the `.dp` extension.
You do not need to write Deep to run the lessons.

## Inspect the addition function

Save this source as `module.ch`. It contains the same `add_vec` definition
as lesson 1, now inside a module:

`module.ch`:

```chelis
module Hello.Basics.HelloTensor
export (add_vec)
def add_vec[n](x: &tensor[n, f32], y: &tensor[n, f32]) -> tensor[n, f32] = add(x, y)
```

`chelis deep module.ch`:

```chelis
(module {surf_path: "Hello.Basics.HelloTensor"}
  hello.basics.hellotensor
  (export {} add_vec)
  (defsig {span: "surf:49..133"}
    add_vec
    (n)
    (t-fn {}
      (t-ref {} (t-tensor {} (d-var {} n) (t-prim {} f32)))
      (t-ref {} (t-tensor {} (d-var {} n) (t-prim {} f32)))
      (t-tensor {} (d-var {} n) (t-prim {} f32))))
  (def {span: "surf:49..133"}
    add_vec
    (fn {}
      (params {} (x {type: (t-var {} _)}) (y {type: (t-var {} _)}))
      (app {span: "surf:124..133"}
        (var {span: "surf:124..127"} add)
        (var {span: "surf:128..129"} x)
        (var {span: "surf:131..132"} y)))))
```

Generate the Deep form yourself:

```sh
chelis deep module.ch
```

Read the generated form alongside the three source lines:

- `module` groups the definition under `Hello.Basics.HelloTensor`.
- `export` names the function that other modules can import.
- `defsig` records `add_vec`'s signature, including its dimension variable `n`.
- `t-ref` represents `&`, the read-only borrow in each parameter type.
- `d-var` represents the variable introduced by `[n]`.
- `def` contains the function body, where `app` applies `add` to `x` and `y`.

The braces after a tag hold metadata. A `span` records a source position
so tools can relate a generated node to the original Surf file. You can
ignore those positions while reading the function's structure.

## A module needs a caller

This module defines and exports `add_vec`, but never calls it. Evaluating
definitions alone does not calculate the sum of two vectors. The first
lesson includes `x`, `y`, and `answer` bindings for that purpose.

To use an exported function, import it by module name and call it from a
top-level binding. Inside a checkout of the hello-chelis repository (set up
as in [Read a larger calculation](capstones.md#set-up-the-package)),
the module above is available as `Hello.Basics.HelloTensor`. Save this as
`add_call.ch` in the checkout's root:

```chelis-surf
import Hello.Basics.HelloTensor (add_vec)
answer = add_vec(to_tensor([1.0f32, 2.0f32, 3.0f32]), to_tensor([4.0f32, 5.0f32, 6.0f32]))
```

`chelis eval --file add_call.ch` prints:

```text
answer = tensor(shape=[3], data=[5.0, 7.0, 9.0])
```

The import list names each function you use. The module path follows the
file's place in the package: `src/basics/hellotensor.ch` holds
`Hello.Basics.HelloTensor`.

## Try another representation

Run `chelis deep addition.ch` on your file from the first lesson. Find the
same signature and function body, then look for the top-level bindings
that supply the inputs and call `add_vec`.

To render a saved Deep file back into Surf, use `chelis surf file.dp`.
The compiler's formatting may differ from the source you wrote. The nodes
listed above are the ones a function definition uses. The
[Surf reference](https://chelis.ch/docs/chelis/surf-reference/) gives every Surf construct
with an example and the Deep form it maps to.
