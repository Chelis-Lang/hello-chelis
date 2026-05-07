module Hello.Coral.Joins

import Coral.Frame (Frame, Column, from_pairs, nrows)
import Coral.Join (inner_join, left_join, outer_join)

export (left_frame, right_frame, inner, left, outer)

-- Customers a, b, c on the left side.
def left_frame() -> Frame[3] = {
  from_pairs([
    ("customer", StringCol(["a", "b", "c"])),
    ("qty", FloatCol(to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])))
  ])
}

-- Customers b, c, d on the right side; b and c overlap with the left.
def right_frame() -> Frame[3] = {
  from_pairs([
    ("customer", StringCol(["b", "c", "d"])),
    ("score", FloatCol(to_tensor([cast(10.0, f32), cast(20.0, f32), cast(30.0, f32)])))
  ])
}

-- Inner join keeps just the {b, c} intersection -> 2 rows.
def inner() -> Frame[2] = inner_join(left_frame(), right_frame(), "customer")

-- Left join keeps every left row -> 3 rows.
def left() -> Frame[3] = left_join(left_frame(), right_frame(), "customer")

-- Outer join keeps the {a, b, c, d} union -> 4 rows.
def outer() -> Frame[4] = outer_join(left_frame(), right_frame(), "customer")
