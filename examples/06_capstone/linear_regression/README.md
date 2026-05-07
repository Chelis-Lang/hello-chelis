# Capstone: Linear Regression with Coral + Std + Nautilus

A complete linear-regression workflow showing how the three numeric shells
compose:

1. **Coral** holds the dataset as a typed `Frame`, with the design matrix
   `X` as a `FloatCol` and the target `y` as another `FloatCol`. Numeric
   columns are tensor-backed, so they participate in the same DAG as the
   model code.
2. **Std** defines the model (`y_hat = X w + b`) and the MSE loss.
3. The training loop is a plain `grad` + manual SGD step.
4. **Nautilus** computes the closed-form solution via `solve` (the normal
   equations: `w_hat = (X^T X)^{-1} X^T y`), and the test asserts the
   `grad`-trained weights converge to the same answer.

## Files

- [`data.ch`](data.ch) — synthetic dataset: y = 2*x_0 + 3*x_1 + 1 + noise.
- [`model.ch`](model.ch) — `predict`, `mse_loss`, one SGD step.
- [`train.ch`](train.ch) — the training loop + a closed-form cross-check
  via `Nautilus.LinAlg.solve` on the normal equations.
