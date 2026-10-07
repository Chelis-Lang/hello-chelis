module Hello.Nautilus.Sde
import Nautilus.Sde (euler_maruyama_fixed)
export (gbm_path_zero_noise, em_one_step_decay)
def gbm_drift(y: f32, t: f32) -> f32 = mul(0.1f32, y)
def gbm_diffusion(y: f32, t: f32) -> f32 = mul(0.2f32, y)
def decay_drift(y: f32, t: f32) -> f32 = neg(y)
def zero_diffusion(y: f32, t: f32) -> f32 = 0.0f32
def gbm_path_zero_noise() -> f32 = {
  noise = to_tensor([0.0f32, 0.0f32, 0.0f32, 0.0f32, 0.0f32, 0.0f32, 0.0f32, 0.0f32, 0.0f32, 0.0f32])
  euler_maruyama_fixed(gbm_drift, gbm_diffusion, 1.0f32, 0.0f32, 1.0f32, noise)
}
def em_one_step_decay() -> f32 = {
  noise = to_tensor([0.0f32])
  euler_maruyama_fixed(decay_drift, zero_diffusion, 1.0f32, 0.0f32, 0.1f32, noise)
}
