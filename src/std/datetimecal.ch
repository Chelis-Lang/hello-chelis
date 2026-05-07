module Hello.Std.DatetimeCal

import Std.Time (Date, date, add_days, sub_days, days_between, date_to_string, day_of_week_name)

export (anniversary, weekday_name, days_until, format_date, after_30_days, week_before, new_years_day)

-- Compute the same date `years` years later by adding 365 * years.
-- (Approximate — does not handle leap years exactly.)
def anniversary(d: Date, years: int64) -> Date =
  add_days(d, mul(years, cast(365, int64)))

-- Look up the weekday name for a date.
def weekday_name(d: Date) -> string =
  day_of_week_name(d)

-- Days from `from` until `to`. Negative if `to` is earlier.
def days_until(from: Date, to: Date) -> int64 =
  days_between(from, to)

-- Render a date as YYYY-MM-DD.
def format_date(d: Date) -> string =
  date_to_string(d)

-- Date 30 days after the given date.
def after_30_days(d: Date) -> Date =
  add_days(d, cast(30, int64))

-- Date 7 days before the given date.
def week_before(d: Date) -> Date =
  sub_days(d, cast(7, int64))

-- Build a New Year's Day date for a given year.
def new_years_day(year: int64) -> Date =
  date(year, cast(1, int64), cast(1, int64))
