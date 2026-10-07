# Five small programs

Work in the empty folder from [Your first program](getting-started.md).
For each lesson, save the source under the filename given, run the commands,
and try the change at the end. Keep your files separate so you can return to
an example that worked.

## 1. Read a tensor type

Save this as `addition.ch`:

`addition.ch`:

```chelis
def add_vec[n](x: &tensor[n, f32], y: &tensor[n, f32]) -> tensor[n, f32] = add(x, y)
x = to_tensor([1.0f32, 2.0f32, 3.0f32])
y = to_tensor([4.0f32, 5.0f32, 6.0f32])
answer = add_vec(x, y)
```

`chelis eval --file addition.ch`:

```text
x = tensor(shape=[3], data=[1.0, 2.0, 3.0])
y = tensor(shape=[3], data=[4.0, 5.0, 6.0])
answer = tensor(shape=[3], data=[5.0, 7.0, 9.0])
```

```sh
chelis check addition.ch
chelis eval --file addition.ch
```

A tensor is a numeric array with a shape. These inputs are vectors, so each
has one dimension: its length. `to_tensor` turns a list into a tensor; the
`f32` suffix makes each literal a 32-bit floating-point value.

Read the function signature from left to right:

- `def add_vec[n]` defines a function with a dimension variable `n`.
- `x: &tensor[n, f32]` takes a read-only borrow of a vector of `f32` values.
- `y` uses the same `n`, so its length must match `x`.
- `-> tensor[n, f32]` gives the result the same length and element precision.
- `add(x, y)` adds corresponding elements.

At this call, the three-element inputs bind `n` to three. The function can
also accept two vectors of length four without changing its definition.
The evaluator shows the inputs and `answer`, so you can check the arithmetic
against the source.

**Try it:** add a fourth element to both lists, using `4.0f32` for `x` and
`7.0f32` for `y`. Check and evaluate the file. The result should have four
elements, with eleven in the last position.

### A dimension variable is not a named axis

The `[n]` after `add_vec` introduces a variable that the checker fills in at
each call. It does not label the data with an axis called `n`.

Chelis also has named dimensions, such as `batch` and `seq`, declared with
`dim`. Those names describe different axes and match by name. Two named axes
do not become interchangeable just because they have the same size. This
lesson uses dimension variables and literal lengths; named axes are covered
in the [type reference](https://chelis.ch/docs/chelis/type-reference/).

## 2. Read a shape error

Save this as `shape_error.ch`. It is deliberately invalid: `y` has only two
elements.

`shape_error.ch`:

```chelis
def add_vec[n](x: &tensor[n, f32], y: &tensor[n, f32]) -> tensor[n, f32] = add(x, y)
x = to_tensor([1.0f32, 2.0f32, 3.0f32])
y = to_tensor([4.0f32, 5.0f32])
answer = add_vec(x, y)
```

`chelis check shape_error.ch`:

```text
DimensionMismatch: `add_vec` argument 2, axis 0: expected 3, got 2
```

```sh
chelis check shape_error.ch
```

The first argument fixes `n` to three. The second would need it to be two.
The diagnostic reports the disagreement at the call, before the addition
runs. Chelis does not stretch the shorter vector or silently repeat its
elements to make the shapes fit.

**Try it:** add `6.0f32` to `y`. Run `check` again, then
`chelis eval --file shape_error.ch`. You have repaired the input contract, so
the program can calculate the same sum as lesson 1. Changing both inputs to
length two is also a valid repair.

## 3. Read an input more than once

Save this as `reuse.ch`:

`reuse.ch`:

```chelis
def double_shared[n](x: &tensor[n, f32]) -> tensor[n, f32] = add(x, x)
def fan_out[n](x: &tensor[n, f32]) -> tensor[n, f32] = add(x, add(x, x))
def take_owned[n](x: tensor[n, f32]) -> tensor[n, f32] = x
x = to_tensor([1.0f32, 2.0f32, 3.0f32])
doubled = double_shared(x)
tripled = fan_out(x)
separate = take_owned(copy(x))
```

`chelis eval --file reuse.ch`:

```text
x = tensor(shape=[3], data=[1.0, 2.0, 3.0])
doubled = tensor(shape=[3], data=[2.0, 4.0, 6.0])
tripled = tensor(shape=[3], data=[3.0, 6.0, 9.0])
separate = tensor(shape=[3], data=[1.0, 2.0, 3.0])
```

```sh
chelis check reuse.ch
chelis eval --file reuse.ch
```

`double_shared` uses its input twice in `add(x, x)`. `fan_out` uses it three
times to add three copies of each value. Both parameters are `&tensor`, so
these are read-only uses of a borrowed input. Calling both functions with
the same `x` is allowed. The results are new tensors.

`take_owned` has a different contract: its parameter is `tensor`, without
`&`. It takes ownership of the tensor passed to it. The final binding passes
`copy(x)`, an explicit separate owner, and calls that result `separate`.
The values are the same as `x`, but this call does not give away the original
owner. Chelis does not insert that copy on your behalf when a borrowed input
is passed to a function that requires ownership.

Do not infer the ownership rule from the number of times a name appears in
a function body. Read the parameter types to see whether the call borrows
or consumes its input.

**Try it:** add `again = double_shared(x)` at the end of the file. Check and
evaluate it. `again` should equal `doubled`. Then change the first input
element to `5.0f32` and predict the first elements of all four results
before running it.

## 4. Choose a numeric precision

Save this as `precision.ch`:

`precision.ch`:

```chelis
x = to_tensor([1.0f32, 2.0f32, 4.0f32])
wider = cast(x, f64)
```

`chelis eval --file precision.ch`:

```text
x = tensor(shape=[3], data=[1.0, 2.0, 4.0])
wider = tensor(shape=[3], data=[1.0, 2.0, 4.0])
```

```sh
chelis check precision.ch
chelis eval --file precision.ch
```

`x` contains `f32` elements. `cast(x, f64)` converts them to 64-bit
floating-point elements. The shape stays the same. The small integers in
this example are exactly representable in both formats, so the values stay
the same too.

Chelis requires an explicit cast when you change precision; it does not
silently promote operands of different precisions. `f64` can represent more
values than `f32`, but widening an already rounded `f32` value cannot recover
the information lost during rounding. Both formats have finite precision.
An explicit type does not make floating-point arithmetic exact.

**Try it:** change `1.0f32` to `0.1f32` and run the program again. The cast
widens the stored `f32` approximation of one tenth. Compare it with a separate
binding, `direct = to_tensor([0.1f64, 2.0f64, 4.0f64])`, where the first literal
is rounded directly to `f64`. Add `same = eq(wider, direct)` and evaluate the
file. The first element of `same` is `false`; the other two are `true`.
This compares the stored values, rather than their printed decimal spellings.

## 5. Differentiate a scalar function

Save this as `gradient.ch`:

`gradient.ch`:

```chelis
def sumsq(theta: tensor[3, f32]) -> f32 = tensor_to_scalar(sum(mul(theta, theta), 0))
theta = to_tensor([1.0f32, 2.0f32, 3.0f32])
loss = sumsq(copy(theta))
slope = grad(sumsq, wrt=theta)(theta)
```

`chelis eval --file gradient.ch`:

```text
theta = tensor(shape=[3], data=[1.0, 2.0, 3.0])
loss = 14.0
slope = tensor(shape=[3], data=[2.0, 4.0, 6.0])
```

```sh
chelis check gradient.ch
chelis eval --file gradient.ch
```

`sumsq` takes exactly three `f32` elements. `mul(theta, theta)` squares each
one, and `sum(..., 0)` adds them along the vector's only axis, numbered zero.
That reduction produces a scalar tensor. `tensor_to_scalar` converts it to
the `f32` value promised by the return type.

For the input one, two, three, the loss is one squared plus two squared plus
three squared: fourteen. The derivative of each square is twice its input,
so the gradient's three elements are two, four, six.

`grad(sumsq, wrt=theta)` constructs the derivative with respect to the
function parameter named `theta`. The final `(theta)` calls it on the
top-level input tensor. The parameter and the top-level binding have the
same spelling here, but serve different roles.

The ordinary loss call uses `sumsq(copy(theta))` because `sumsq` takes an
owned tensor. That explicit copy leaves the original available for the
gradient call. Removing it would consume the input before the next call.

**Try it:** replace the input with `[-1.0f32, 0.0f32, 4.0f32]`. Work out the
loss and the three derivatives before running the file. You should get a
loss of seventeen and derivatives of negative two, zero, and eight.

You can now read a tensor signature, repair a shape mismatch, distinguish a
borrow from an owned argument, choose a precision, and call `grad`. Continue
with [Surf and Deep](fundamentals.md) to inspect a function's
representation, or [capstone reading](capstones.md) to trace
a larger calculation.
