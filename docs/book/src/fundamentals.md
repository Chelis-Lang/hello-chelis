# Surf and Deep

The `.ch` files in the lessons use Surf, Chelis's readable source syntax.
The compiler can render their structure as Deep, an s-expression syntax
with nested parentheses and tagged nodes. Deep files use the `.dp` extension.
You do not need to write Deep to run the lessons.

## Inspect the addition function

Save this source as `module.ch`. It contains the same `add_vec` definition
as lesson 1, now inside a module:

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
- `defsig` records `add_vec`'s signature: its name, the dimension variables
  it introduces (`(n)`), and its type.
- `t-fn` is a function type. Its children are the parameter types in order,
  then the result type.
- `t-tensor` is a tensor type: its dimensions, then its element type.
- `d-var` is a dimension written as a variable, here the `n` from `[n]`.
- `t-prim` is a primitive type such as `f32`.
- `t-ref` represents `&`, the read-only borrow in each parameter type. The
  result has no `t-ref`, so the caller owns it.
- `def` holds the body. `fn` is the function value, and `params` lists `x`
  and `y`. Their `(t-var {} _)` types are placeholders: the checker takes
  the real types from `defsig`.
- `app` applies its first child, `(var add)`, to the remaining children, the
  variables `x` and `y`.

The braces after a tag hold metadata. A `span` records a source position
so tools can relate a generated node to the original Surf file. You can
ignore those positions while reading the function's structure.

## A module needs a caller

This module defines and exports `add_vec`, but never calls it. Evaluating
definitions alone does not calculate the sum of two vectors. The first
lesson includes `x`, `y`, and `answer` bindings for that purpose.

To call an exported function from another file, the module has to sit in
a Reef package at the path its name gives. The package's `module_prefix`
supplies `Hello`, and the rest of the name maps to a lowercase path under
`src/`: `Hello.Basics.HelloTensor` lives in `src/basics/hellotensor.ch`.
Create a package with that prefix and move your module there:

```sh
chelis reef init lessons --module-prefix Hello --output lessons
mkdir -p lessons/src/basics
mv module.ch lessons/src/basics/hellotensor.ch
cd lessons
```

Save this as `add_call.ch` in the package root, next to `reef.toml`:

```chelis-surf
import Hello.Basics.HelloTensor (add_vec)
answer = add_vec(to_tensor([1.0f32, 2.0f32, 3.0f32]), to_tensor([4.0f32, 5.0f32, 6.0f32]))
```

`chelis eval --file add_call.ch` prints:

```text
answer = tensor(shape=[3], data=[5.0, 7.0, 9.0])
```

The import list names each function you use. If the file's path does not
match the module name, the import fails. With the module saved as `src/module.ch`, the
same command stops with:

```text
error: module `Hello.Basics.HelloTensor` does not match file path module.ch (expected `hello.module`)
```

A checkout of the hello-chelis repository already holds this module at
`src/basics/hellotensor.ch`, so the same `add_call.ch` also runs in its root.

## Try another representation

Run `chelis deep addition.ch` on your file from the first lesson. Find the
same signature and function body, then look for the top-level bindings
that supply the inputs and call `add_vec`.

To render a saved Deep file back into Surf, use `chelis surf file.dp`.
The compiler's formatting may differ from the source you wrote. The nodes
listed above are the ones a function definition uses. The
[Surf reference](https://chelis.ch/docs/chelis/surf-reference/) gives every Surf construct
with an example and the Deep form it maps to.
