import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/models/recharge_transaction.dart';

class UserRechargeHistoryState {
  const UserRechargeHistoryState({
    this.transactions = const [],
    this.status = LoadStatus.loading,
    this.errorMessage,
    this.page = 1,
    this.totalPages = 1,
    this.firstIndex = 0,
  });

  final List<RechargeTransaction> transactions;
  final LoadStatus status;
  final String? errorMessage;
  final int page;
  final int totalPages;
  final int firstIndex;
}
