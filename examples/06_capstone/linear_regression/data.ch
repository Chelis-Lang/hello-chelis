module Hello.Capstone.LinReg.Data

import Std.Tensor.Construct (to_tensor)
import Coral.Frame (Frame, from_pairs)

export (design_matrix, targets, dataframe)

// Six samples, two features. Generated from y = 2*x0 + 3*x1 + 1 with no
// noise so the closed-form / SGD comparison is exact.
def design_matrix() -> tensor[n, m, f32] =
  to_tensor([
    [1.0, 0.0],
    [0.0, 1.0],
    [1.0, 1.0],
    [2.0, 1.0],
    [1.0, 2.0],
    [2.0, 2.0]
  ])

def targets() -> tensor[n, f32] =
  // 2*x0 + 3*x1 + 1
  to_tensor([3.0, 4.0, 6.0, 8.0, 9.0, 11.0])

def dataframe() -> Frame =
  from_pairs([
    ("x0", FloatCol(to_tensor([1.0, 0.0, 1.0, 2.0, 1.0, 2.0]))),
    ("x1", FloatCol(to_tensor([0.0, 1.0, 1.0, 1.0, 2.0, 2.0]))),
    ("y",  FloatCol(targets()))
  ])
