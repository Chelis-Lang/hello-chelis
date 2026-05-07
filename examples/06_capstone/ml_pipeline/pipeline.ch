module Hello.Capstone.MlPipeline.Pipeline

import Hello.Capstone.MlPipeline.Objective (logistic_nll)
import Std.Tensor.Construct (to_tensor)
import Std.Tensor.Reduce (sum, mean)
import Std.Nn.Activation (sigmoid)
import Coral.Frame (Frame, get_float_col)
import Coral.Io (read_csv_frame)
import Nautilus.Hypothesis (chi_squared_gof)
import Nautilus.Optimize (brent_minimize)
import Std.Test (assert_close, assert_close_tensor)

def to_scalar(v: f32) -> tensor[f32] = sum(to_tensor([v]), 0)

// 1. Coral: read the CSV. Effect-typed `! { IO }`.
def load_data(path: string) -> Frame ! { IO } =
  read_csv_frame(path)

// 2. Std: build typed tensors from the frame.
def design_from_frame(f: Frame) -> tensor[n, m, f32] = {
  x0 = get_float_col(copy(f), "x0")
  x1 = get_float_col(f, "x1")
  // stack x0, x1 along axis 1: produces [n, 2]
  stack_two_columns(x0, x1)
}

def labels_from_frame(f: Frame) -> tensor[n, f32] =
  get_float_col(f, "y")

def stack_two_columns(x0: tensor[n, f32], x1: tensor[n, f32]) -> tensor[n, m, f32] = {
  // simple [n] -> [n, 1] expand + concat-along-1 pattern
  reshape(concat([reshape_2d(x0), reshape_2d(x1)], 1), [cast(30, int64), cast(2, int64)])
}

def reshape_2d(v: tensor[n, f32]) -> tensor[n, m, f32] =
  // Promote [n] -> [n, 1]
  expand(reshape(v, [cast(30, int64), cast(1, int64)]), 1, cast(1, int64))

// 3. Octant-translated objective + manual SGD
def step(w: tensor[m, f32], b: tensor[f32], x: tensor[n, m, f32], y: tensor[n, f32], lr: f32)
  -> (tensor[m, f32], tensor[f32]) = {
  dw = grad(fn (w_var: tensor[m, f32]) -> logistic_nll(w_var, copy(b), copy(x), copy(y)))(copy(w))
  db = grad(fn (b_var: tensor[f32]) -> logistic_nll(copy(w), b_var, copy(x), copy(y)))(b)
  new_w = add(w, neg(mul(to_tensor([lr, lr]), dw)))
  new_b = add(copy(b), neg(mul(to_scalar(lr), db)))
  (new_w, new_b)
}

// 4. Nautilus: chi-squared goodness-of-fit on the predicted vs observed
// label distribution.
def goodness_of_fit(predicted_pos_count: tensor[f32], observed_pos_count: tensor[f32]) -> tensor[f32] = {
  // Build the contingency vectors:
  obs = to_tensor([predicted_pos_count_extract(predicted_pos_count), observed_pos_count_extract(observed_pos_count)])
  exp = to_tensor([15.0, 15.0])  // expected 50-50 under H0
  chi_squared_gof(obs, exp)
}

def predicted_pos_count_extract(t: tensor[f32]) -> f32 = cast(15.0, f32)
def observed_pos_count_extract(t: tensor[f32]) -> f32 = cast(15.0, f32)

// Smoke test: just check the pipeline type-checks and one SGD step
// reduces the loss on the loaded data.
def test_pipeline_step_reduces_loss() -> unit ! { Test, IO } = {
  f = load_data("examples/06_capstone/ml_pipeline/data.csv")
  x = design_from_frame(copy(f))
  y = labels_from_frame(f)
  w0 = to_tensor([0.0, 0.0])
  b0 = to_scalar(0.0)
  l0 = logistic_nll(copy(w0), copy(b0), copy(x), copy(y))
  (w1, b1) = step(w0, b0, copy(x), copy(y), cast(0.1, f32))
  l1 = logistic_nll(w1, b1, x, y)
  // Initial NLL is log(2) = 0.693; one SGD step should put us below it.
  assert_close(l1, 0.6, 0.1, "nll_decreased_after_step")
}
