# Compiler vs Interpreter Discrepancies (v0.17.1)

Catalogued during the porting work. The compiler ships three distinct
execution paths that don't all share the same primitive set:

- **front-end** — `chelis check`. Parser + type/dim/effect/linearity
  checking. The most permissive: accepts every Surf form the spec
  describes.
- **IR evaluator (host runtime)** — `chelis eval`, `chelis test`.
  Interactive in-process execution. Limited primitive set on v0.17.1.
- **C backend** — `chelis build --target c`. Production code path.
  Different (and on some primitives complementary) limitations.

A program can pass `chelis check` and fail in either runtime, and pass
in one runtime but fail in the other. The discrepancies below were all
hit while porting this corpus; each item is a real compiler error
message verbatim or a reproducible behavior.

## Transforms (`grad`, `vmap`, `jit`, `realize`)

### `grad`: not in host runtime
> ```
> FAIL (host runtime does not support `grad`)
> ```
> Status: rejected by `chelis test`.
> Workaround: exercise via the C backend (`verify/grad_works.ch`).

### `grad`: C backend rejects the inline application form
> ```
> error: `chelis build --target c` can't lower these defs — their
> body applies/binds `grad` (or `vmap`) in a position the host lane
> can't resolve (inline `grad(f)(x)` or `g = grad(f); g(x)`).
> Workaround that compiles today: make the function you want to
> differentiate a parameter of the enclosing def, then call
> `grad(local, wrt=(arg))(arg)` where `local` is a locally-bound fn
> that uses the parameter; and make sure that function uses only
> pure tensor ops (sum, add, mul, einsum, etc.) — `grad` through
> host-lane `fold`/`map` is not currently supported, rewrite to
> `tensor_to_scalar(sum(mul(v, v), 0))` or `einsum`.
> ```
> Status: `grad(f, wrt=w)(w, x)` accepted by `chelis check`,
> rejected by `chelis build`. The wrapper-fn-param form
> (`fn (w_local) -> model(w_local, x)`) lowers cleanly.
> See `verify/grad_works.ch` for the compiling form.

### `grad`: refactoring src/ to the wrapper form breaks `chelis test`
> ```
> FAIL (compile: lowered root count mismatch: expected N named
> roots, got N-2)
> ```
> Status: changing `src/basics/gradbasic.ch` to the wrapper-fn-param
> form caused project-wide breakage in the IR evaluator — every test
> in the project failed to compile, regardless of whether the test
> itself imported gradbasic. Internal accounting between the named-
> roots walker and the lowering pass diverges on the new shape.
> Workaround: keep the inline form in src/ (the `chelis check` and
> `chelis test` lanes accept it), put the lowering form in verify/.

### `realize`: not in host runtime
> ```
> FAIL (host runtime does not support `realize`)
> ```
> Status: rejected by `chelis test`. Lowers cleanly via C backend
> (`verify/realize_lowers.ch`).

### `vmap`: parallel restriction with `grad`
The compiler error message for `grad` lowering also mentions
`vmap` — same wrapper-fn-param form is required for both transforms
through the C backend.

## Tensor primitives

### Activations not in host runtime
> ```
> FAIL (unsupported builtin `relu` in host runtime)
> FAIL (unsupported builtin `sigmoid` in host runtime)
> ```
> Status: tensor `relu`, `sigmoid`, and (per chelis-std SKILL.md)
> `gelu`, `silu`, `tanh` are check-clean but the IR evaluator
> doesn't ship them. C backend handles them.

### Tensor `cast` precision restrictions
> ```
> error: cannot cast tensor to unsupported element precision
> `bf16` (supported: f32, f64, bool, int8, int32, int64)
> ```
> Status: `cast(tensor, bf16)` rejected by `chelis check`. `bf16`
> is reserved syntax but no precision conversion implemented.
> Workaround: use f64 / int32 / etc.

### `copy` rejects scalars
> ```
> error: copy requires tensor input, got f32
> ```
> Status: `copy(scalar)` rejected by `chelis check`. Scalars don't
> have linearity, so `copy` is a tensor-only operation.

## Shape and dimension issues

### `expand` broadcast shape divergence
> ```
> FAIL (tensor shapes must match for elementwise op, got [64, 1] vs [64])
> ```
> Status: `expand(b: tensor[1, f32], 0, 64)` is typed as
> `tensor[64, 1, f32]` by `chelis check` but the IR evaluator
> produces `tensor[64, f32]` at runtime, breaking
> `add(matmul_output, expanded_bias)` whose matmul side really is
> rank 2. Hit in `src/capstone/linreg.ch::predict`. The same shape
> appears in upstream's own `examples/linreg.ch` (in the chelis
> source repo, separate from this corpus), so the issue is tracked as a
> general compiler/runtime divergence rather than a hello-chelis-only
> fixture bug.

### `to_tensor` doesn't accept 2D Python-style literals
> ```
> error: to_tensor expects numeric or bool List elements, got List f32
> ```
> Status: `to_tensor([[1.0, 2.0], [3.0, 4.0]])` rejected.
> Workaround: `pad_sequences([[...], [...]], 0.0)` per upstream's
> `tensor_structural_ops.ch`.

### Fixed-shape C smoke fixtures lower on v0.17.1

The v0.7.6 symbolic-dimension C-codegen panic no longer applies to
the current verify fixtures. `verify/grad_works.ch`,
`verify/relu_lowers.ch`, `verify/relu_then_sigmoid.ch`, and
`verify/sigmoid_lowers.ch` now build, link, run, and golden-diff in
`tests/test_c_backend.py`.

The v0.17.1 checker does reject signatures that declare a polymorphic
dimension while the function body fixes that dimension to a concrete
literal, such as subtracting a length-3 literal vector from
`tensor[n, f32]`. The current corpus makes those example shapes
explicit with `tensor[3, f32]`.

### Higher-order f32 wrappers fail in C codegen
> ```
> grad_polynomial.c:122: error: implicit declaration of function 'dpoly'
> ```
> Status: a function with signature
> `(model: f32 -> f32, x: f32) -> f32` referencing `model(x)`
> doesn't get its wrapper definition emitted in C. Same pattern
> with `tensor[n, f32]` return type works fine.

### Pipe operator drops shape on tensor activation chains in C
> ```
> $ ./pipe_relu_sigmoid
> xs = tensor(shape=[3], data=[-1.0, 0.0, 1.0])
> out = ()
> ```
> Status: `xs |> relu |> sigmoid` lowers but produces unit-typed
> output. Use direct calls: `sigmoid(relu(xs))` works. Affects only
> the C backend; `chelis check` accepts the pipe form.

## Effect handlers

### `with seed(...)` rejected by C backend, project-wide
> ```
> error: `chelis build --target c` does not yet plumb `with
> seed(...)` into the generated runtime; rejecting rather than
> silently dropping the seed. Run the seeded program through
> `chelis eval` instead.
> ```
> Status: ANY `with seed(...)` anywhere in the project source tree
> blocks `chelis build` of EVERY file. Affects
> `src/basics/effectsrandom.ch::deterministic_pair` — even building
> a sibling capstone fails because the project as a whole contains
> the gate-tripping construct. Per the message, fully exercising
> seeded RNG requires `chelis eval`.

## CLI and harness ergonomics

### `chelis check` is single-file only
> ```
> error: unexpected argument 'examples/' found
> ```
> Status: `chelis check examples/` rejected. Must iterate per-file.
> The CI harness invokes it once per `.ch` via pytest parametrization.

### `chelis test` rejects single-file paths from outside repo root
> ```
> error: path `tests/basics/hellotensor.ch` does not exist —
> pass a tests directory or a single .ch file
> ```
> Status: only resolvable from the project root (where `reef.toml`
> lives). Run via `cd <repo> && chelis test ...`.

### `chelis test --jobs auto` is the native default
> ```
> chelis test tests/ --jobs auto
> ```
> Status: on v0.17.1 the full native tree passes under node-local
> concurrency. Use `chelis test tests/ --jobs 1` only as a serial
> fallback for debugging output.

### `chelis surf` decompile is best-effort
List literals decompile to `Cons/Nil` chains, `cast(x, f32)` to
`(x as f32)`, etc. Re-deepifying the decompiled Surf produces a
different (but semantically equivalent) Deep AST. We don't enforce
round-trip identity; the drift check (`.dp` matches `chelis deep
<ch>`) is the load-bearing equivalence guarantee.

### Reef install requires `GITHUB_TOKEN` for private shells
> ```
> error: ... GITHUB_TOKEN is not set and `gh auth token` did not
> yield a token ... export GITHUB_TOKEN=$(gh auth token) and retry
> ```
> Status: the public release-asset URL doesn't serve bytes for
> chelis-lang's private repos during pre-launch.
> The Dockerfile uses the canonical release path with a BuildKit
> `github_token` secret: `chelis reef install --from-github` downloads
> each prebuilt shell package instead of cloning and rebuilding shell
> repos.

## Where each gap shows up in this corpus

| Gap | Affected file(s) | Workaround |
|---|---|---|
| `grad` not in host runtime | `tests/capstone/blackscholes.ch` | `verify/grad_quadratic.ch` exercises C backend |
| `realize` not in host runtime | (would-be `tests/basics/jitrealize.ch`) | `verify/realize_lowers.ch` exercises C backend |
| Tensor activations not in host runtime | `tests/basics/pipeandmatch.ch` | Test file uses `neg`/`add` chain instead of `relu`/`sigmoid` |
| v0.7.6 symbolic-dim C-codegen panic | historical `verify/grad_works.ch` and activation verify fixture shapes | resolved on v0.7.26; now normal golden-output C-backend tests |
| `expand` shape divergence | `src/capstone/linreg.ch` | check-only; build-only via verify |
| `with seed` blocks `chelis build` | `src/basics/effectsrandom.ch` | Project-wide build limited; verify/ programs are bare modules |
| `cast(t, bf16)` rejected | `src/basics/precisioncast.ch` | Test uses f32→f64→f32 round trip |

## Status of each item upstream

The chelis_phase3_plan.md cited in error messages tracks several of
these as "Acknowledged Limitations" (Batch 7b for the `with seed`
gate). The `grad` lowering form is documented as the workaround in
`crates/chelis-cli/tests/cli.rs::build_c_tensor_grad_local_wrapper_*`.
The activation kernels still need broader host-runtime coverage, but
their current C-backend lowering is covered by normal golden-output
tests.

This document is descriptive, not prescriptive — fixes belong upstream.
