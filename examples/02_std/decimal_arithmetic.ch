module Hello.Std.DecimalArithmetic

import Std.Decimal (Decimal, decimal_of_string, decimal_add, decimal_mul, decimal_to_string)
import Std.Test (assert_eq_string)

// `Decimal[P, S]` is parameterized by precision P (total significant
// digits) and scale S (digits after the point). Both are tracked at
// compile time. `Decimal[10, 2]` is "up to 10 digits, 2 after the point"
// — adequate for most currency.

def cents(x: string) -> Decimal[10, 2] =
  decimal_of_string(x)

def add_currency(a: Decimal[10, 2], b: Decimal[10, 2]) -> Decimal[10, 2] =
  decimal_add(a, b)

// 100.00 * 0.05 = 5.00 -> Decimal[12, 4] in the result type. The compiler
// adds the scales (2 + 2 = 4) and bumps precision to fit the worst-case
// product (10 + 2 = 12).
def gross_up(a: Decimal[10, 2], rate: Decimal[10, 2]) -> Decimal[12, 4] =
  decimal_mul(a, rate)

def test_add_currency() -> unit ! { Test } = {
  a = cents("19.95")
  b = cents("0.05")
  out = add_currency(a, b)
  assert_eq_string(decimal_to_string(out), "20.00", "currency_sum")
}

def test_gross_up() -> unit ! { Test } = {
  principal = cents("100.00")
  rate = cents("0.05")
  out = gross_up(principal, rate)
  assert_eq_string(decimal_to_string(out), "5.0000", "gross_up")
}
