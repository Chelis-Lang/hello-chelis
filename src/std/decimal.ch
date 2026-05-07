module Hello.Std.Decimal

import Std.Decimal (Decimal, decimal, decimal_from_int, decimal_add, decimal_sub, decimal_mul, decimal_to_string)

export (price_with_tax, total_cents, parse_price, format_total, add_cents)

-- Parse a price string like "19.95" into a Decimal.
def parse_price(text: string) -> Decimal =
  decimal(text)

-- Add two Decimals; useful for summing line items.
def total_cents(a: Decimal, b: Decimal) -> Decimal =
  decimal_add(a, b)

-- Apply a tax multiplier (e.g. "1.0825" for 8.25% sales tax) to a base
-- price, then add the original to demonstrate compositional pricing.
-- Pure decimal arithmetic — no f32 rounding error.
def price_with_tax(base: Decimal, tax_multiplier: Decimal) -> Decimal =
  decimal_mul(base, tax_multiplier)

-- Subtract a discount and convert to a string for display.
def format_total(subtotal: Decimal, discount: Decimal) -> string = {
  net = decimal_sub(subtotal, discount)
  decimal_to_string(net)
}

-- Demonstrate constructing a Decimal from an int and adding cents.
def add_cents(price: Decimal, cents: int64) -> Decimal = {
  -- 1 cent = Decimal { coefficient: 1, scale: 2 }
  delta = Decimal { coefficient: cents, scale: cast(2, int64) }
  decimal_add(price, delta)
}
