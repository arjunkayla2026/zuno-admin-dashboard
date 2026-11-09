import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';

enum PaymentTab { withdrawalList, pending, success }

class PaymentState {
  const PaymentState({
    required this.withdrawals,
    required this.minimumWithdrawal,
    required this.tdsPercent,
    required this.today,
    this.tab = PaymentTab.withdrawalList,
    this.query = '',
    this.page = 1,
  });

  static const int pageSize = 10;

  final List<Withdrawal> withdrawals;
  final int minimumWithdrawal;
  final int tdsPercent;
  final DateTime today;
  final PaymentTab tab;
  final String query;
  final int page;

  List<Withdrawal> get pendingWithdrawals =>
      withdrawals.where((withdrawal) => withdrawal.isPending).toList();

  int get pendingCount => pendingWithdrawals.length;

  int get successCount => withdrawals.length - pendingCount;

  int _sumPending(int Function(Withdrawal withdrawal) value) =>
      pendingWithdrawals.fold(0, (sum, withdrawal) => sum + value(withdrawal));

  int get pendingEarned => _sumPending((withdrawal) => withdrawal.amountEarned);

  int get pendingMinutes => _sumPending((withdrawal) => withdrawal.callMinutes);

  int get pendingCredit => _sumPending((withdrawal) => withdrawal.hostCredit);

  int get pendingTotal => _sumPending((withdrawal) => withdrawal.totalAmount);

  bool _matchesQuery(Withdrawal withdrawal) {
    final term = query.trim().toLowerCase();
    if (term.isEmpty) return true;
    return [
      withdrawal.hostName,
      withdrawal.hostId,
      withdrawal.withdrawId,
    ].any((text) => text.toLowerCase().contains(term));
  }

  static int _byDateThenId(Withdrawal a, Withdrawal b) {
    final byDate = b.date.compareTo(a.date);
    return byDate != 0 ? byDate : a.withdrawId.compareTo(b.withdrawId);
  }

  static int _bySettledDateDescending(Withdrawal a, Withdrawal b) {
    final byDate = b.settledDate.compareTo(a.settledDate);
    return byDate != 0 ? byDate : b.withdrawId.compareTo(a.withdrawId);
  }

  List<Withdrawal> get visibleWithdrawals {
    final matches = withdrawals.where(_matchesQuery);
    return switch (tab) {
      PaymentTab.withdrawalList => matches.toList()..sort(_byDateThenId),
      PaymentTab.pending =>
        matches.where((withdrawal) => withdrawal.isPending).toList()
          ..sort((a, b) => a.withdrawId.compareTo(b.withdrawId)),
      PaymentTab.success =>
        matches.where((withdrawal) => !withdrawal.isPending).toList()
          ..sort(_bySettledDateDescending),
    };
  }

  int get totalPages {
    final count = visibleWithdrawals.length;
    if (count == 0) return 1;
    return (count / pageSize).ceil();
  }

  int get firstIndex => (page - 1) * pageSize;

  List<Withdrawal> get pageWithdrawals =>
      visibleWithdrawals.skip(firstIndex).take(pageSize).toList();

  PaymentState copyWith({
    List<Withdrawal>? withdrawals,
    PaymentTab? tab,
    String? query,
    int? page,
  }) {
    return PaymentState(
      withdrawals: withdrawals ?? this.withdrawals,
      minimumWithdrawal: minimumWithdrawal,
      tdsPercent: tdsPercent,
      today: today,
      tab: tab ?? this.tab,
      query: query ?? this.query,
      page: page ?? this.page,
    );
  }
}
