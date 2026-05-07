-- chelis-expect-fail: UseAfterConsume
--
-- x is consumed by relu(x) on the second line, then referenced again
-- in add(x, y). The compiler must reject this with the canonical
-- UseAfterConsume diagnostic and a hint to insert copy(x).



def bad(x: tensor[n, f32]) -> tensor[n, f32] = {
  y = relu(x)
  add(x, y)
}
