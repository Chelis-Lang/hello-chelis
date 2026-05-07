module Hello.Nautilus.Distance

import Nautilus.Distance (euclidean, manhattan, chebyshev, cosine_distance)

export (euclid, manhattan_dist, chebyshev_dist, cosine_dist, self_distance_zero)

-- Euclidean (L2) distance between two equal-length vectors.
def euclid(a: tensor[n, f32], b: tensor[n, f32]) -> f32 =
  euclidean(a, b)

-- Manhattan (L1) distance.
def manhattan_dist(a: tensor[n, f32], b: tensor[n, f32]) -> f32 =
  manhattan(a, b)

-- Chebyshev (L-inf) distance.
def chebyshev_dist(a: tensor[n, f32], b: tensor[n, f32]) -> f32 =
  chebyshev(a, b)

-- Cosine distance (1 - cosine_similarity).
def cosine_dist(a: tensor[n, f32], b: tensor[n, f32]) -> f32 =
  cosine_distance(a, b)

-- Identity property: euclidean(x, x) = 0.
def self_distance_zero(x: tensor[n, f32]) -> f32 =
  euclidean(copy(x), x)
