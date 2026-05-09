module Hello.Tests.Std.ReductionsLosses
import Hello.Std.ReductionsLosses (kl_loss, ce_perplexity)
import Std.Test (assert_close)
def test_kl_loss_self_is_zero() -> unit ! { Test } = {
  p = to_tensor([cast(0.5, f32), cast(0.5, f32)])
  q = to_tensor([cast(0.5, f32), cast(0.5, f32)])
  result = kl_loss(p, q)
  __borrow_migration_out_0 = assert_close(result, cast(0.0, f32), cast(0.000001, f32), "KL(p||p)=0")
  _ = drop(q)
  _ = drop(p)
  __borrow_migration_out_0
}
def test_perplexity_zero_loss_is_one() -> unit ! { Test } = {
  result = ce_perplexity(cast(0.0, f32))
  assert_close(result, cast(1.0, f32), cast(0.000001, f32), "perplexity(0)=1")
}
def test_perplexity_unit_loss() -> unit ! { Test } = {
  result = ce_perplexity(cast(1.0, f32))
  assert_close(result, cast(2.7182817, f32), cast(0.0001, f32), "perplexity(1)=e")
}
