import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/core/enums/wallet_adjustment_type.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.date,
    required this.type,
    required this.amount,
    required this.description,
  });

  factory WalletTransaction.fromLedger(String id, Map<String, dynamic> data) {
    final value = data['amount'];
    final amount = value is num ? value.toDouble() : 0.0;
    final entryType = data[typeField];
    final description =
        UserRecord.readText(data['description']) ??
        switch (entryType) {
          callEarningType => AppStrings.callEarnings,
          adminCreditType => AppStrings.adminCredit,
          adminDebitType => AppStrings.adminDebit,
          payoutType => AppStrings.payoutLedgerDescription(
            UserRecord.readText(data['withdrawId']) ?? AppStrings.emptyValue,
          ),
          _ => AppStrings.emptyValue,
        };
    return WalletTransaction(
      id: id,
      date:
          UserRecord.readDate(data[createdAtField]) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      type: amount < 0
          ? WalletAdjustmentType.debit
          : WalletAdjustmentType.credit,
      amount: NumberFormatter.roundAmount(amount.abs()),
      description: description,
    );
  }

  static const String collection = 'ledger';
  static const String uidField = 'uid';
  static const String typeField = 'type';
  static const String createdAtField = 'createdAt';
  static const String callEarningType = 'call_earning';
  static const String adminCreditType = 'host_admin_credit';
  static const String adminDebitType = 'host_admin_debit';
  static const String payoutType = 'host_payout';
  static const List<String> creditTypes = [callEarningType, adminCreditType];
  static const List<String> debitTypes = [adminDebitType, payoutType];

  final String id;
  final DateTime date;
  final WalletAdjustmentType type;
  final double amount;
  final String description;

  bool get isCredit => type == WalletAdjustmentType.credit;

  bool get hasAmount => amount > 0;

  static List<String> typesFor(WalletAdjustmentType? type) => switch (type) {
    WalletAdjustmentType.credit => creditTypes,
    WalletAdjustmentType.debit => debitTypes,
    null => [...creditTypes, ...debitTypes],
  };
}
