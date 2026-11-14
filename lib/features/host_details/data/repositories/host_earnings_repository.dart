import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/record_page.dart';
import 'package:zuno_admin_dashboard/core/enums/wallet_adjustment_type.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/features/host_details/data/datasources/host_earnings_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/host_details/data/models/host_earnings_totals.dart';
import 'package:zuno_admin_dashboard/features/host_details/data/models/wallet_transaction.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';

class HostEarningsRepository {
  const HostEarningsRepository(this._dataSource);

  final HostEarningsRemoteDataSource _dataSource;

  Future<Either<Failure, HostEarningsTotals>> fetchTotals(String hostId) =>
      _dataSource.fetchTotals(hostId);

  Future<Either<Failure, int>> countWithdrawals(String hostId) =>
      _dataSource.countWithdrawals(hostId);

  Future<Either<Failure, RecordPage<Withdrawal>>> fetchWithdrawals(
    String hostId, {
    Object? cursor,
  }) async {
    final page = await _dataSource.fetchWithdrawalPage(hostId, cursor: cursor);
    switch (page) {
      case Left():
        return page;
      case Right(value: final loaded)
          when !loaded.items.any((item) => item.isPending):
        return page;
      case Right(value: final loaded):
        final account = await _dataSource.fetchApprovedBankAccount(hostId);
        return account.map(
          (bankAccount) => loaded.mapItems(
            (items) => [
              for (final item in items)
                item.isPending ? item.withBankAccount(bankAccount) : item,
            ],
          ),
        );
    }
  }

  Future<Either<Failure, RecordPage<WalletTransaction>>> fetchWallet(
    String hostId, {
    WalletAdjustmentType? type,
    Object? cursor,
  }) => RecordPages.untilMatch(
    cursor,
    (next) => _dataSource.fetchWalletPage(
      hostId,
      types: WalletTransaction.typesFor(type),
      cursor: next,
    ),
    (batch) => batch.where((transaction) => transaction.hasAmount),
  );

  Future<Either<Failure, Unit>> adjust(
    String hostId, {
    required WalletAdjustmentType type,
    required int amount,
    required String description,
  }) => _dataSource.adjust(
    hostId: hostId,
    isCredit: type == WalletAdjustmentType.credit,
    amount: amount,
    description: description,
    requestId: _dataSource.newRequestId(),
  );
}
