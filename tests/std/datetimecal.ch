module Hello.Tests.Std.DatetimeCal

import Hello.Std.DatetimeCal (days_until, format_date, after_30_days, week_before, new_years_day)
import Std.Time (date)
import Std.Test (assert_eq_int, assert_eq_string)

def test_days_until() -> unit ! { Test } = {
  jan_1 = date(cast(2026, int64), cast(1, int64), cast(1, int64))
  jan_31 = date(cast(2026, int64), cast(1, int64), cast(31, int64))
  diff = days_until(jan_1, jan_31)
  assert_eq_int(diff, cast(30, int64), "30 days from Jan 1 to Jan 31")
}

def test_format_and_offset() -> unit ! { Test } = {
  d = date(cast(2026, int64), cast(5, int64), cast(7, int64))
  later = after_30_days(d)
  assert_eq_string(format_date(later), "2026-06-06", "May 7 + 30 days = Jun 6")
}

def test_week_before() -> unit ! { Test } = {
  d = new_years_day(cast(2026, int64))
  earlier = week_before(d)
  assert_eq_string(format_date(earlier), "2025-12-25", "7 days before Jan 1, 2026 is Dec 25, 2025")
}
