module Hello.Coral.WindowRolling
import Coral.Window (rolling_mean, rolling_std, ewm)
export (sample_series, mean3, std3, ewm_half)
def sample_series() -> tensor[5, f32] = { to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32), cast(4.0, f32), cast(5.0, f32)]) }
def mean3() -> tensor[5, f32] = rolling_mean(sample_series(), cast(3, int64))
def std3() -> tensor[5, f32] = rolling_std(sample_series(), cast(3, int64))
def ewm_half() -> tensor[5, f32] = ewm(sample_series(), cast(0.5, f32))
