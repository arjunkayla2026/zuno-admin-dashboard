import 'package:cloud_firestore/cloud_firestore.dart';

abstract final class DeletedAccountRecord {
  static const String document = 'admin_earnings/deletedAccountProfits';
  static const String incomeAmountField = 'incomeAmount';
  static const String deletedAtField = 'deletedAt';

  static double? incomeOf(Map<String, dynamic>? data, String id) {
    final entry = data?[id];
    if (entry is! Map) return null;
    final income = entry[incomeAmountField];
    return income is num ? income.toDouble() : null;
  }

  static double totalOf(
    Map<String, dynamic>? data, {
    DateTime? from,
    DateTime? until,
  }) {
    var total = 0.0;
    for (final entry in (data ?? const <String, dynamic>{}).values) {
      if (entry is! Map) continue;
      final income = entry[incomeAmountField];
      if (income is! num) continue;
      if (from != null && until != null) {
        final deletedAt = entry[deletedAtField];
        if (deletedAt is! Timestamp) continue;
        final time = deletedAt.toDate();
        if (time.isBefore(from) || !time.isBefore(until)) continue;
      }
      total += income;
    }
    return total;
  }
}
