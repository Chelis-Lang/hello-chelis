# 06 — Capstones

Multi-shell integration. Each capstone has its own folder with a `README.md`
explaining the integration, plus all the source files needed to run it.

| Capstone | Shells | Why it's interesting |
|---|---|---|
| [`black_scholes_greeks/`](black_scholes_greeks/) | octant + nautilus + std | The headline AD demo: write Black-Scholes in LaTeX, translate it through Octant, take `grad` to compute Greeks (delta, gamma, vega), cross-check against finite differences. |
| [`linear_regression/`](linear_regression/) | coral + std + nautilus | Build a Coral frame, define an MSE loss in std, train via `grad` + a manual SGD loop, compare the learned coefficients to Nautilus's `solve` of the normal equations. |
| [`transformer_block/`](transformer_block/) | std (only) | The primer's transformer-block walkthrough as a runnable, tested example. Demonstrates linearity, named dims, and `grad` over a non-trivial DAG. |
| [`ml_pipeline/`](ml_pipeline/) | all four | Coral CSV → feature engineering → Octant-translated objective → `grad`-driven training → Nautilus statistical evaluation. The "everything bagel". |
