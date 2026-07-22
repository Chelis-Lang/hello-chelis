# Grad through Black-Scholes `normal_cdf` returns a tensor-bool condition

## Filing condition

File against `Chelis-Lang/chelis` after confirming the minimal Nautilus-free control identifies whether the bool-tensor condition originates in grad lowering or host evaluation of a package function.

## Observed at Chelis 0.16.1

`Hello.Capstone.BlackScholes.delta` checks cleanly, but `chelis test` fails at runtime:

```text
if condition must be bool, got Tensor(RuntimeTensorValue { ... precision: Bool })
```

The direct scalar control `grad(square, wrt=x)(x)` evaluates and compiles correctly, so the trigger is inside the `normal_cdf` call graph rather than scalar grad generally.

## Acceptance

The expected delta at `s=k=100`, `r=0.05`, `sigma=0.2`, `t=1` is approximately `0.6368`; vega is approximately `37.524`. Promote the blocked probe only when both exact-value assertions pass in the native test lane.
