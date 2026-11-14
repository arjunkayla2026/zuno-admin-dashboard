import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/payout_settings.dart';
import 'package:zuno_admin_dashboard/core/data/record_page.dart';
import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/core/data/users_remote_data_source.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/payout_summary.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';

class WithdrawalListCursor {
  const WithdrawalListCursor({required this.inPaid, this.cursor});

  final bool inPaid;
  final Object? cursor;
}

class PaymentRepository {
  const PaymentRepository(this._dataSource, this._usersDataSource);

  static const String _hostRole = 'host';
  static const String _withdrawIdPrefix = 'WD-';
  static const int _maxPaidSearchHosts = 30;
  static const int _pageSize = RecordPageQuery.pageSize;

  final PaymentRemoteDataSource _dataSource;
  final UsersRemoteDataSource _usersDataSource;

  Future<Either<Failure, double?>> fetchMinimumPayout() =>
      _dataSource.fetchMinimumPayout();

  Future<Either<Failure, PayoutSummary>> fetchSummary(double? minimum) =>
      _dataSource.fetchEligibleSummary(minimum);

  Future<Either<Failure, int>> countPaid() => _dataSource.countPaid();

  Future<Either<Failure, RecordPage<Withdrawal>>> fetchEligiblePage({
    required double? minimum,
    Object? cursor,
  }) async {
    final page = await _dataSource.fetchEligiblePage(
      minimum: minimum,
      cursor: cursor,
    );
    return _withBankAccounts(page);
  }

  Future<Either<Failure, RecordPage<Withdrawal>>> fetchPaidPage({
    Object? cursor,
  }) => _dataSource.fetchPaidPage(cursor: cursor);

  Future<Either<Failure, RecordPage<Withdrawal>>> fetchListPage({
    required double? minimum,
    Object? cursor,
  }) async {
    final position = cursor is WithdrawalListCursor
        ? cursor
        : const WithdrawalListCursor(inPaid: false);
    if (position.inPaid) return _paidListPage(position.cursor, _pageSize);

    final pending = await fetchEligiblePage(
      minimum: minimum,
      cursor: position.cursor,
    );
    switch (pending) {
      case Left():
        return pending;
      case Right(value: final page) when page.nextCursor != null:
        return right(
          RecordPage(
            page.items,
            nextCursor: WithdrawalListCursor(
              inPaid: false,
              cursor: page.nextCursor,
            ),
          ),
        );
      case Right(value: final page):
        final remaining = _pageSize - page.items.length;
        if (remaining <= 0) {
          return right(
            RecordPage(
              page.items,
              nextCursor: const WithdrawalListCursor(inPaid: true),
            ),
          );
        }
        final paid = await _paidListPage(null, remaining);
        return paid.map(
          (paidPage) => RecordPage([
            ...page.items,
            ...paidPage.items,
          ], nextCursor: paidPage.nextCursor),
        );
    }
  }

  Future<Either<Failure, List<Withdrawal>>> search(
    String term, {
    required double? minimum,
    required bool includePending,
    required bool includePaid,
  }) async {
    final text = term.trim();
    bool keep(Withdrawal withdrawal) => withdrawal.isPending
        ? includePending &&
              withdrawal.totalAmount >= PayoutSettings.eligibleFrom(minimum)
        : includePaid;

    if (text.toUpperCase().startsWith(_withdrawIdPrefix)) {
      final found = await _dataSource.fetchByWithdrawId(text.toUpperCase());
      return _attachBankAccounts(found.map((items) => items.where(keep)));
    }

    final hosts = await _usersDataSource.searchUsers(_hostRole, text);
    switch (hosts) {
      case Left(value: final failure):
        return left(failure);
      case Right(value: final records):
        final results = await Future.wait([
          if (includePending)
            _dataSource.fetchByIds(records.map(_pendingPayoutIdOf).nonNulls),
          if (includePaid)
            _dataSource.fetchPaidForHosts(
              records.take(_maxPaidSearchHosts).map((record) => record.id),
            ),
        ]);
        final matches = Either.sequenceList(results).map((lists) {
          final found = lists.expand((items) => items).where(keep).toList();
          final pending = found.where((item) => item.isPending).toList()
            ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
          final paid = found.where((item) => !item.isPending).toList()
            ..sort((a, b) => b.settledDate.compareTo(a.settledDate));
          return [...pending, ...paid];
        });
        return _attachBankAccounts(matches);
    }
  }

  Future<Either<Failure, Withdrawal>> completePayout(
    Withdrawal withdrawal,
  ) async {
    final result = await _dataSource.completePayout(
      payoutId: withdrawal.id,
      expectedTotalAmount: withdrawal.totalAmount,
    );
    return result.map(
      (receipt) => withdrawal.markedPaid(receipt, DateTime.now()),
    );
  }

  Future<Either<Failure, RecordPage<Withdrawal>>> _paidListPage(
    Object? cursor,
    int pageSize,
  ) async {
    final page = await _dataSource.fetchPaidPage(
      cursor: cursor,
      pageSize: pageSize,
    );
    return page.map(
      (paid) => RecordPage(
        paid.items,
        nextCursor: paid.nextCursor == null
            ? null
            : WithdrawalListCursor(inPaid: true, cursor: paid.nextCursor),
      ),
    );
  }

  Future<Either<Failure, RecordPage<Withdrawal>>> _withBankAccounts(
    Either<Failure, RecordPage<Withdrawal>> page,
  ) async {
    switch (page) {
      case Left():
        return page;
      case Right(value: final loaded):
        final items = await _attachBankAccounts(right(loaded.items));
        return items.map(
          (withAccounts) =>
              RecordPage(withAccounts, nextCursor: loaded.nextCursor),
        );
    }
  }

  Future<Either<Failure, List<Withdrawal>>> _attachBankAccounts(
    Either<Failure, Iterable<Withdrawal>> withdrawals,
  ) async {
    switch (withdrawals) {
      case Left(value: final failure):
        return left(failure);
      case Right(value: final items):
        final list = items.toList();
        final hostIds = {
          for (final item in list)
            if (item.isPending && item.hostId.isNotEmpty) item.hostId,
        };
        if (hostIds.isEmpty) return right(list);
        final accounts = await _dataSource.fetchApprovedBankAccounts(hostIds);
        return accounts.map(
          (byHost) => [
            for (final item in list)
              item.isPending ? item.withBankAccount(byHost[item.hostId]) : item,
          ],
        );
    }
  }

  static String? _pendingPayoutIdOf(UserRecord record) =>
      UserRecord.readText(record.hostDetails[Withdrawal.pendingPayoutIdField]);
}
