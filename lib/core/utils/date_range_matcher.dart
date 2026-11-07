import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/enums/date_range_filter.dart';

extension DateRangeMatcher on DateRangeFilter {
  bool includes(
    DateTime moment, {
    required DateTime today,
    DateTimeRange? customRange,
  }) {
    final date = DateTime(moment.year, moment.month, moment.day);
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
    if (start == null || end == null) return true;
    return !date.isBefore(start) && !date.isAfter(end);
  }
}
