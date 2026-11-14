import 'dart:math';

import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';

abstract final class PayoutSettings {
  static const String minimumPayoutField = 'minimumPayoutAmount';
  static const int tdsPercent = 2;
  static const double _smallestPayout = 0.01;

  static double? readMinimum(Object? value) =>
      value is num && value.isFinite && value >= 0
      ? NumberFormatter.roundAmount(value.toDouble())
      : null;

  static double eligibleFrom(double? minimum) =>
      max(minimum ?? 0, _smallestPayout);
}
