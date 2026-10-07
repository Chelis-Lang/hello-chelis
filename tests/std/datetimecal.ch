module Hello.Tests.Std.DatetimeCal
import Hello.Std.DatetimeCal (anniversary, days_until, format_date, after_30_days, week_before, new_years_day)
import Std.Datetime (date)
import Std.Test (assert_eq)
def test_days_until() -> unit ! { Test } = {
  jan_1 = date(2026i64, 1i64, 1i64)
  jan_31 = date(2026i64, 1i64, 31i64)
  diff = days_until(jan_1, jan_31)
  assert_eq(diff, 30i64, "30 days from Jan 1 to Jan 31")
}
def test_format_and_offset() -> unit ! { Test } = {
  d = date(2026i64, 5i64, 7i64)
  later = after_30_days(d)
  assert_eq(format_date(later), "2026-06-06", "May 7 + 30 days = Jun 6")
}
def test_week_before() -> unit ! { Test } = {
  d = new_years_day(2026i64)
  earlier = week_before(d)
  assert_eq(format_date(earlier), "2025-12-25", "7 days before Jan 1, 2026 is Dec 25, 2025")
}
def test_anniversary_leap_day() -> unit ! { Test } = {
  leap_day = date(2024i64, 2i64, 29i64)
  assert_eq(format_date(anniversary(leap_day, 1i64)), "2025-02-28", "anniversary clamps leap day")
}
