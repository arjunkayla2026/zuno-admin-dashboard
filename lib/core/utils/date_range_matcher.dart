import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/enums/date_range_filter.dart';

extension DateRangeMatcher on DateRangeFilter {
  (DateTime?, DateTime?) dayBounds({
    required DateTime today,
    DateTimeRange? customRange,
  }) {
    final (start, end) = switch (this) {
      DateRangeFilter.all => (null, null),
      DateRangeFilter.yesterday => (
        today.subtract(const Duration(days: 1)),
        today.subtract(const Duration(days: 1)),
      ),
      DateRangeFilter.last7Days => (
        today.subtract(const Duration(days: 6)),
        today,
      ),
      DateRangeFilter.last30Days => (
        today.subtract(const Duration(days: 29)),
        today,
      ),
      DateRangeFilter.custom => (customRange?.start, customRange?.end),
    };
    if (start == null || end == null) return (null, null);
    return (_dayOf(start), _dayOf(end));
  }

  (DateTime?, DateTime?) momentBounds({
    required DateTime today,
    DateTimeRange? customRange,
  }) {
    final (start, end) = dayBounds(today: today, customRange: customRange);
    if (start == null || end == null) return (null, null);
    return (start, DateTime(end.year, end.month, end.day + 1));
  }

  bool includes(
    DateTime moment, {
    required DateTime today,
    DateTimeRange? customRange,
  }) {
    final (start, end) = dayBounds(today: today, customRange: customRange);
    if (start == null || end == null) return true;
    final date = _dayOf(moment);
    return !date.isBefore(start) && !date.isAfter(end);
  }

  static DateTime _dayOf(DateTime moment) =>
      DateTime(moment.year, moment.month, moment.day);
}
