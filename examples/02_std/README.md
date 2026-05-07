# 02 — chelis-std

Surfaces from the standard library: activations, normalizations, reductions,
losses, decimals, datetimes, collections, and tensor I/O.

| File | Surface |
|---|---|
| [`activations_norms.ch`](activations_norms.ch) | `Std.Nn.Activation`, `Std.Nn.Norm` |
| [`reductions_losses.ch`](reductions_losses.ch) | `Std.Tensor.Reduce`, `Std.Nn.Loss` |
| [`decimal_arithmetic.ch`](decimal_arithmetic.ch) | `Std.Decimal.Decimal[P, S]` with compile-time precision |
| [`datetime_calendar.ch`](datetime_calendar.ch) | `Std.Time.DateTime` / `Duration` / `BusinessDay` |
| [`collections_iteration.ch`](collections_iteration.ch) | `List`, `Dict`, `map` / `filter` / `fold` / `scan` |
| [`tensor_io.ch`](tensor_io.ch) | `Std.Io` read/write, effect-typed `! { IO }` |
