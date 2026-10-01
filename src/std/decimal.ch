module Hello.Std.Decimal
import Std.Decimal (Decimal, decimal, decimal_from_int, decimal_add, decimal_sub, decimal_mul, decimal_to_string)
export (price_with_tax, total_cents, parse_price, format_total, add_cents)
def parse_price(text: string) -> Decimal = decimal(text)
def total_cents(a: Decimal, b: Decimal) -> Decimal = decimal_add(a, b)
def price_with_tax(base: Decimal, tax_multiplier: Decimal) -> Decimal = decimal_mul(base, tax_multiplier)
def format_total(subtotal: Decimal, discount: Decimal) -> string = {
  net = decimal_sub(subtotal, discount)
  decimal_to_string(net)
}
def add_cents(price: Decimal, cents: i64) -> Decimal = {
  delta = Decimal { coefficient: cents, scale: 2i64 }
  decimal_add(price, delta)
}
