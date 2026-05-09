module Hello.Nautilus.Sde
import Nautilus.Sde (euler_maruyama_fixed)
export (gbm_path_zero_noise, em_one_step_decay)
def gbm_drift(y: f32, t: f32) -> f32 = mul(cast(0.1, f32), y)
def gbm_diffusion(y: f32, t: f32) -> f32 = mul(cast(0.2, f32), y)
def decay_drift(y: f32, t: f32) -> f32 = neg(y)
def zero_diffusion(y: f32, t: f32) -> f32 = cast(0.0, f32)
def gbm_path_zero_noise() -> f32 = {
  noise = to_tensor([cast(0.0, f32), cast(0.0, f32), cast(0.0, f32), cast(0.0, f32), cast(0.0, f32), cast(0.0, f32), cast(0.0, f32), cast(0.0, f32), cast(0.0, f32), cast(0.0, f32)])
  euler_maruyama_fixed(gbm_drift, gbm_diffusion, cast(1.0, f32), cast(0.0, f32), cast(1.0, f32), noise)
}
def em_one_step_decay() -> f32 = {
  noise = to_tensor([cast(0.0, f32)])
  euler_maruyama_fixed(decay_drift, zero_diffusion, cast(1.0, f32), cast(0.0, f32), cast(0.1, f32), noise)
}
