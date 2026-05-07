module Hello.Tests.Std.Decimal

import Hello.Std.Decimal (parse_price, total_cents, format_total, add_cents)
import Std.Decimal (decimal, decimal_to_string, decimal_eq)
import Std.Test (assert_eq_string, assert_true)

def test_parse_and_format() -> unit ! { Test } = {
  price = parse_price("19.95")
  assert_eq_string(decimal_to_string(price), "19.95", "round-trip")
}

def test_total_cents_sum() -> unit ! { Test } = {
  a = decimal("1.50")
  b = decimal("2.25")
  total = total_cents(a, b)
  assert_eq_string(decimal_to_string(total), "3.75", "1.50+2.25=3.75")
}

def test_format_total_with_discount() -> unit ! { Test } = {
  subtotal = decimal("100.00")
  discount = decimal("15.50")
  out = format_total(subtotal, discount)
  assert_eq_string(out, "84.5", "100.00-15.50=84.5")
}

def test_add_cents() -> unit ! { Test } = {
  base = decimal("10.00")
  bumped = add_cents(base, cast(7, int64))
  -- 10.00 + 0.07 = 10.07
  assert_true(decimal_eq(bumped, decimal("10.07")), "add 7 cents")
}
