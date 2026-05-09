module Hello.Nautilus.Distance
import Nautilus.Distance (euclidean, manhattan, chebyshev, cosine_distance)
export (euclid, manhattan_dist, chebyshev_dist, cosine_dist, self_distance_zero)
def euclid(a: &tensor[n, f32], b: &tensor[n, f32]) -> f32 = euclidean(a, b)
def manhattan_dist(a: &tensor[n, f32], b: &tensor[n, f32]) -> f32 = manhattan(a, b)
def chebyshev_dist(a: &tensor[n, f32], b: &tensor[n, f32]) -> f32 = chebyshev(a, b)
def cosine_dist(a: &tensor[n, f32], b: &tensor[n, f32]) -> f32 = cosine_distance(a, b)
def self_distance_zero(x: &tensor[n, f32]) -> f32 = euclidean(x, x)
