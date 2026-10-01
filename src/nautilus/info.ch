module Hello.Nautilus.Info
import Nautilus.Info (entropy, kl_divergence)
export (shannon_entropy, relative_entropy)
def shannon_entropy[n](p: &tensor[n, f32]) -> f32 = entropy(p)
def relative_entropy[n](p: &tensor[n, f32], q: &tensor[n, f32]) -> f32 = kl_divergence(p, q)
