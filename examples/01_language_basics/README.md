# 01 — Language basics

Pure-language features. Every example here type-checks against the
`chelis-std` baseline (no other shell deps). Read in order.

| File | Feature |
|---|---|
| [`01_hello_tensor.ch`](01_hello_tensor.ch) | named dimensions, no implicit broadcasting |
| [`02_pipe_and_match.ch`](02_pipe_and_match.ch) | the `\|>` pipe operator, ADTs, exhaustive `match` |
| [`03_modules_and_imports/`](03_modules_and_imports/) | multi-file module with all 3 import forms |
| [`04_dimension_polymorphism.ch`](04_dimension_polymorphism.ch) | bracketed dim parameters `[a, b]` |
| [`05_precision_and_cast.ch`](05_precision_and_cast.ch) | no implicit precision promotion; `cast` as the explicit fix |
| [`06_effects_random.ch`](06_effects_random.ch) | `! { Random }` effect rows + `with seed(...)` handlers |
| [`07_linearity_copy_borrow.ch`](07_linearity_copy_borrow.ch) | consume-by-default, `copy`, `&borrow` |
| [`08_grad_basic.ch`](08_grad_basic.ch) | reverse-mode AD with `grad` |
| [`09_vmap.ch`](09_vmap.ch) | per-example function lifted to batched function |
| [`10_jit_and_realize.ch`](10_jit_and_realize.ch) | `jit` build-target lifting, `realize` forced eval, `cast` precision change |
| [`11_macro_basic.ch`](11_macro_basic.ch) | a macro expanding to typed Deep |
