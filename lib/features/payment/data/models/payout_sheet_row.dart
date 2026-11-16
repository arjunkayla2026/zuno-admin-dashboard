import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/features/host_details/data/models/wallet_transaction.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';

/// An admin credit or debit `ledger` entry written against a payout.
class PayoutAdjustment {
  const PayoutAdjustment({
    required this.payoutId,
    required this.isCredit,
    required this.description,
    this.createdAt,
  });

  static PayoutAdjustment? fromLedger(Map<String, dynamic> data) {
    final payoutId = UserRecord.readText(data['payoutId']);
    final description = UserRecord.readText(data['description']);
    final isCredit = switch (data[WalletTransaction.typeField]) {
      WalletTransaction.adminCreditType => true,
      WalletTransaction.adminDebitType => false,
      _ => null,
    };
    if (payoutId == null || description == null || isCredit == null) {
      return null;
    }
    return PayoutAdjustment(
      payoutId: payoutId,
      isCredit: isCredit,
      description: description,
      createdAt: UserRecord.readDate(data[WalletTransaction.createdAtField]),
    );
  }

  final String payoutId;
  final bool isCredit;
  final String description;
  final DateTime? createdAt;
}

/// Admin remarks written on a payout's credit and debit adjustments.
class PayoutRemarks {
  const PayoutRemarks({this.credit = const [], this.debit = const []});

  final List<String> credit;
  final List<String> debit;
}

/// One pending payout with everything the bank upload sheets need.
class PayoutSheetRow {
  const PayoutSheetRow({
    required this.withdrawal,
    required this.bankAccount,
    this.fullName,
    this.district,
    this.state,
    this.remarks = const PayoutRemarks(),
  });

  final Withdrawal withdrawal;
  final PayoutBankAccount bankAccount;
  final String? fullName;
  final String? district;
  final String? state;
  final PayoutRemarks remarks;
}
