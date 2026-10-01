module Hello.Coral.WindowRolling
import Coral.Window (rolling_mean, rolling_std, ewm)
export (sample_series, mean3, std3, ewm_half)
def sample_series() -> tensor[5, f32] = to_tensor([1.0f32, 2.0f32, 3.0f32, 4.0f32, 5.0f32])
def mean3() -> tensor[5, f32] = rolling_mean(sample_series(), 3i64)
def std3() -> tensor[5, f32] = rolling_std(sample_series(), 3i64)
def ewm_half() -> tensor[5, f32] = ewm(sample_series(), 0.5f32)
