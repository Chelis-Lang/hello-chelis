module Hello.Std.DatetimeCalendar

import Std.Time (
  DateTime,
  Duration,
  BusinessDay,
  datetime_of_iso,
  duration_days,
  add_duration,
  add_business_days,
  datetime_to_iso,
  is_business_day
)
import Std.Test (assert_eq_string, assert_true, assert_false)

// `DateTime` is timezone-aware. `Duration` is calendar-arithmetic-aware.
// `BusinessDay` skips weekends (and a calendar-supplied holiday list).

def shift_calendar(d: DateTime, days: int64) -> DateTime =
  add_duration(d, duration_days(days))

def shift_business(d: DateTime, days: int64) -> DateTime =
  add_business_days(d, days)

def test_calendar_shift() -> unit ! { Test } = {
  d = datetime_of_iso("2026-05-07T00:00:00Z")
  // +3 calendar days from a Thursday is Sunday
  out = shift_calendar(d, cast(3, int64))
  assert_eq_string(datetime_to_iso(out), "2026-05-10T00:00:00Z", "cal_plus_3")
}

def test_business_skips_weekend() -> unit ! { Test } = {
  // Thursday May 7, 2026 + 1 business day -> Friday May 8
  // Thursday May 7, 2026 + 2 business days -> Monday May 11 (skips Sat/Sun)
  d = datetime_of_iso("2026-05-07T00:00:00Z")
  next1 = shift_business(d, cast(1, int64))
  next2 = shift_business(copy(d), cast(2, int64))
  assert_eq_string(datetime_to_iso(next1), "2026-05-08T00:00:00Z", "biz_plus_1")
  assert_eq_string(datetime_to_iso(next2), "2026-05-11T00:00:00Z", "biz_plus_2")
}

def test_is_business_day() -> unit ! { Test } = {
  thu = datetime_of_iso("2026-05-07T00:00:00Z")
  sat = datetime_of_iso("2026-05-09T00:00:00Z")
  assert_true(is_business_day(thu), "thursday")
  assert_false(is_business_day(sat), "saturday")
}
