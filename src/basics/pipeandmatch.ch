module Hello.Basics.PipeAndMatch
export (Activation, activate, pipeline)
type Activation =
  | Relu
  | Sigmoid
def activate(act: Activation, x: &tensor[n, f32]) -> tensor[n, f32] = {
  match act with {
    | Relu => relu(x)
    | Sigmoid => sigmoid(x)
  }
}
def pipeline(x: &tensor[n, f32]) -> tensor[n, f32] = sigmoid(relu(x))
