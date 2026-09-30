module Hello.Tests.Nautilus.Info
import Hello.Nautilus.Info (shannon_entropy, relative_entropy)
import Std.Test (assert_close)
def fair_coin() -> tensor[2, f32] = to_tensor([cast(0.5, f32), cast(0.5, f32)])
def test_entropy_fair_coin_is_ln2() -> unit ! { Test } = assert_close(shannon_entropy(fair_coin()), cast(0.6931472, f32), cast(0.0001, f32), "H(fair coin)=ln 2")
def test_kl_self_is_zero() -> unit ! { Test } = assert_close(relative_entropy(fair_coin(), fair_coin()), cast(0.0, f32), cast(1e-6, f32), "KL(p||p)=0")
def test_kl_biased_coin() -> unit ! { Test } = {
  q = to_tensor([cast(0.25, f32), cast(0.75, f32)])
  assert_close(relative_entropy(fair_coin(), q), cast(0.143841, f32), cast(0.0001, f32), "KL(fair||biased)")
}
