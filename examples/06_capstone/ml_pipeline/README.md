# Capstone: end-to-end ML pipeline (all four shells)

A small, complete data-science workflow that touches every shipped Chelis
shell:

1. **Coral** loads a CSV file into a typed `Frame`, applies a `group_by`
   for per-class statistics, and joins in a feature lookup table.
2. **Std** does feature engineering: normalize, build training tensors.
3. **Octant** translates the LaTeX form of our objective (negative
   log-likelihood for a logistic regression) into Chelis Deep.
4. We train via `grad` + manual SGD; the gradient flows through the
   Octant-translated objective and the Coral-derived design matrix.
5. **Nautilus** gives us the statistical evaluation: confusion matrix
   summary statistics, a chi-squared goodness-of-fit, and a Brent
   minimization of the regularization strength on a validation split.

This is the most ambitious example in the repo. It demonstrates that the
shells compose without ceremony — the pipeline is just function
composition all the way down, with every step type-checked, every
dimension named, and every fan-out marked with `copy`.

## Files

- [`pipeline.ch`](pipeline.ch) — the full pipeline; reads from
  [`data.csv`](data.csv) at runtime.
- [`objective.tex`](objective.tex) — logistic NLL written in LaTeX.
- [`objective.ch`](objective.ch) — verified `octant translate` output.
- [`data.csv`](data.csv) — synthetic 30-sample binary classification set.
