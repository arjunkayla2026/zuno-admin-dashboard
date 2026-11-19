import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/app_environment/config/flavor_config.dart';
import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/core/enums/app_environment.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/repositories/host_management_repository.dart';
import 'package:zuno_admin_dashboard/features/payment/data/datasources/mock_withdrawals_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/mock_withdrawal_summary.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';

class MockWithdrawalsRepository {
  const MockWithdrawalsRepository(this._dataSource);

  static const String _totalWithdrawnKey = 'totalWithdrawel';

  final MockWithdrawalsRemoteDataSource _dataSource;

  /// Mock withdrawals exist only on staging; the callables refuse elsewhere.
  bool get isAvailable =>
      FlavorConfig.instance.environment == Environment.staging;

  Future<Either<Failure, MockWithdrawalSummary>> fetchSummary() async {
    final (hosts, payouts) = await (
      _dataSource.fetchMockHosts(),
      _dataSource.fetchMockPayouts(),
    ).wait;
    return hosts.flatMap(
      (records) => payouts.map((items) => _summaryOf(records, items)),
    );
  }

  Future<Either<Failure, ({int hosts, int payouts})>> generate() async =>
      (await _dataSource.seed()).map(
        (data) => (
          hosts: _countOf(data['hosts']),
          payouts: _countOf(data['payouts']),
        ),
      );

  Future<Either<Failure, int>> clear() async =>
      (await _dataSource.reset()).map((data) => _countOf(data['deleted']));

  static int _countOf(Object? value) => value is num ? value.round() : 0;

  static MockWithdrawalSummary _summaryOf(
    List<UserRecord> hosts,
    List<Withdrawal> payouts,
  ) {
    final paidByHost = <String, double>{};
    for (final payout in payouts) {
      if (!payout.isPaid) continue;
      paidByHost[payout.hostId] =
          (paidByHost[payout.hostId] ?? 0) + payout.totalAmount;
    }
    final recorded = [
      for (final host in hosts)
        MockHostTotals(
          hostId: host.id,
          hostName:
              UserRecord.readText(host.hostDetails['userName']) ??
              host.userName ??
              AppStrings.emptyValue,
          hostUserId: host.userID ?? AppStrings.emptyValue,
          recordedWithdrawn: switch (HostManagementRepository.hostEarningsOf(
            host.hostDetails,
          )[_totalWithdrawnKey]) {
            final num amount => amount.toDouble(),
            _ => 0,
          },
          successRecordsTotal: paidByHost[host.id] ?? 0,
        ),
    ]..sort((a, b) => a.hostName.compareTo(b.hostName));
    return MockWithdrawalSummary(withdrawals: payouts, hosts: recorded);
  }
}
