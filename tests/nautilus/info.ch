module Hello.Tests.Nautilus.Info
import Hello.Nautilus.Info (shannon_entropy, relative_entropy)
import Std.Test (assert_close)
def fair_coin() -> tensor[2, f32] = to_tensor([0.5f32, 0.5f32])
def test_entropy_fair_coin_is_ln2() -> unit ! { Test } = assert_close(shannon_entropy(fair_coin()), 0.6931472f32, 0.0001f32, "H(fair coin)=ln 2")
def test_kl_self_is_zero() -> unit ! { Test } = assert_close(relative_entropy(fair_coin(), fair_coin()), 0.0f32, 1e-6f32, "KL(p||p)=0")
def test_kl_biased_coin() -> unit ! { Test } = {
  q = to_tensor([0.25f32, 0.75f32])
  assert_close(relative_entropy(fair_coin(), q), 0.143841f32, 0.0001f32, "KL(fair||biased)")
}
