import 'package:zuno_admin_dashboard/core/enums/wallet_adjustment_type.dart';

class WalletTransaction {
  const WalletTransaction({
    required this.date,
    required this.type,
    required this.amount,
    required this.description,
  });

  final DateTime date;
  final WalletAdjustmentType type;
  final int amount;
  final String description;

  bool get isCredit => type == WalletAdjustmentType.credit;
}
