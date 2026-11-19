import 'dart:math';

import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/payout_settings.dart';
import 'package:zuno_admin_dashboard/core/data/record_page.dart';
import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/core/data/users_remote_data_source.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/payout_batch_result.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/payout_beneficiary.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/payout_failure_reason.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/payout_sheet_row.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/payout_summary.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';

class PaymentRepository {
  const PaymentRepository(this._dataSource, this._usersDataSource);

  static const int selectAllLimit = 1000;
  static const String _hostRole = 'host';
  static const String _withdrawIdPrefix = 'WD-';
  static const int _maxSearchHosts = 30;
  static const int _batchSize = 50;
  static const Duration _istOffset = Duration(hours: 5, minutes: 30);

  final PaymentRemoteDataSource _dataSource;
  final UsersRemoteDataSource _usersDataSource;

  Future<Either<Failure, double?>> fetchMinimumPayout() =>
      _dataSource.fetchMinimumPayout();

  Future<Either<Failure, PayoutSummary>> fetchSummary(double? minimum) =>
      _dataSource.fetchOpenSummary(minimum);

  Future<Either<Failure, int>> countPending() => _dataSource.countPending();

  Future<Either<Failure, int>> countPaid({DateTime? from, DateTime? until}) =>
      _dataSource.countPaid(from: from, until: until);

  Future<Either<Failure, int>> countFailed() => _dataSource.countFailed();

  Future<Either<Failure, RecordPage<Withdrawal>>> fetchOpenPage({
    required double? minimum,
    Object? cursor,
  }) async =>
      (await _withBankAccounts(
        await _dataSource.fetchOpenPage(minimum: minimum, cursor: cursor),
      )).map(
        (page) => RecordPage(
          page.items.where((item) => item.hasBankAccount).toList(),
          nextCursor: page.nextCursor,
        ),
      );

  Future<Either<Failure, RecordPage<Withdrawal>>> fetchPendingPage({
    Object? cursor,
  }) async =>
      _withBankAccounts(await _dataSource.fetchPendingPage(cursor: cursor));

  Future<Either<Failure, RecordPage<Withdrawal>>> fetchPaidPage({
    Object? cursor,
    DateTime? from,
    DateTime? until,
  }) => _dataSource.fetchPaidPage(cursor: cursor, from: from, until: until);

  Future<Either<Failure, RecordPage<Withdrawal>>> fetchFailedPage({
    Object? cursor,
  }) async =>
      _withBankAccounts(await _dataSource.fetchFailedPage(cursor: cursor));

  Future<Either<Failure, List<Withdrawal>>> fetchAll(
    WithdrawalStatus status, {
    required double? minimum,
  }) async {
    final found = switch (status) {
      WithdrawalStatus.open => await _dataSource.fetchAllOpen(
        minimum,
        limit: selectAllLimit,
      ),
      WithdrawalStatus.pending => await _dataSource.fetchAllPending(
        limit: selectAllLimit,
      ),
      WithdrawalStatus.failed => await _dataSource.fetchAllFailed(
        limit: selectAllLimit,
      ),
      WithdrawalStatus.success ||
      WithdrawalStatus.forfeited => right<Failure, List<Withdrawal>>(const []),
    };
    return _readyOnly(await _attachBankAccounts(found));
  }

  Future<Either<Failure, List<Withdrawal>>> search(
    String term, {
    required double? minimum,
    required WithdrawalStatus status,
    DateTime? paidFrom,
    DateTime? paidUntil,
  }) async {
    final text = term.trim();
    bool paidInRange(Withdrawal withdrawal) {
      if (!withdrawal.isPaid || (paidFrom == null && paidUntil == null)) {
        return true;
      }
      final paidOn = withdrawal.paidOn;
      return paidOn != null &&
          (paidFrom == null || !paidOn.isBefore(paidFrom)) &&
          (paidUntil == null || paidOn.isBefore(paidUntil));
    }

    bool keep(Withdrawal withdrawal) =>
        withdrawal.status == status &&
        paidInRange(withdrawal) &&
        (!withdrawal.isOpen ||
            withdrawal.totalAmount >= PayoutSettings.eligibleFrom(minimum));

    if (text.toUpperCase().startsWith(_withdrawIdPrefix)) {
      final found = await _dataSource.fetchByWithdrawId(text.toUpperCase());
      return _readyOnly(
        await _attachBankAccounts(
          found.map((items) => items.where(keep).toList()),
        ),
      );
    }

    final (hosts, snapshotMatches) = await (
      _usersDataSource.searchUsers(_hostRole, text),
      _dataSource.searchBySnapshot(text),
    ).wait;
    switch (hosts) {
      case Left(value: final failure):
        return left(failure);
      case Right(value: final records):
        final hostIds = records
            .take(_maxSearchHosts)
            .map((record) => record.id);
        final byHost = await switch (status) {
          WithdrawalStatus.open => _dataSource.fetchByIds(
            records.map(_pendingPayoutIdOf).nonNulls,
          ),
          WithdrawalStatus.pending => _dataSource.fetchPendingForHosts(hostIds),
          WithdrawalStatus.success => _dataSource.fetchPaidForHosts(
            hostIds,
            from: paidFrom,
            until: paidUntil,
          ),
          WithdrawalStatus.failed => _dataSource.fetchFailedForHosts(hostIds),
          WithdrawalStatus.forfeited => Future.value(
            right<Failure, List<Withdrawal>>(const []),
          ),
        };
        final found = byHost.flatMap(
          (items) => snapshotMatches.map(
            (extra) => {
              for (final item in [...items, ...extra]) item.id: item,
            }.values.toList(),
          ),
        );
        final matches = found.map((items) {
          final kept = items.where(keep).toList();
          return status == WithdrawalStatus.open
              ? (kept..sort((a, b) => b.totalAmount.compareTo(a.totalAmount)))
              : (kept..sort((a, b) => b.settledDate.compareTo(a.settledDate)));
        });
        return _readyOnly(await _attachBankAccounts(matches));
    }
  }

  /// Builds the beneficiary sheet rows for [withdrawals] and registers each
  /// host as a beneficiary: a host keeps its `hostDetails.beneficiaryId`
  /// while its bank account is unchanged and gets a new one otherwise.
  Future<Either<Failure, List<PayoutSheetRow>>> fetchBeneficiarySheetRows(
    List<Withdrawal> withdrawals,
  ) async {
    final rows = await fetchSheetRows(withdrawals);
    switch (rows) {
      case Left():
        return rows;
      case Right(value: final loaded):
        if (loaded.isEmpty) return rows;
        final registered = await _dataSource.registerBeneficiaries({
          for (final row in loaded)
            row.withdrawal.hostId: PayoutBeneficiary.fingerprint(
              row.withdrawal.hostId,
              row.bankAccount,
            ),
        });
        return registered.map(
          (ids) => [
            for (final row in loaded)
              row.withBeneficiaryId(ids[row.withdrawal.hostId]),
          ],
        );
    }
  }

  /// Builds the bank sheet rows for [withdrawals], skipping mock payouts and
  /// any without an approved bank account. Joins each host's `hostDetails`
  /// (including a beneficiary ID still valid for the current bank account)
  /// and the admin credit / debit remarks written against the payout.
  Future<Either<Failure, List<PayoutSheetRow>>> fetchSheetRows(
    List<Withdrawal> withdrawals,
  ) async {
    final ready = withdrawals
        .where((item) => item.hasBankAccount && !item.isMock)
        .toList();
    if (ready.isEmpty) return right(const []);
    final (hosts, adjustments) = await (
      _usersDataSource.fetchByIds(ready.map((item) => item.hostId)),
      _dataSource.fetchAdjustments(ready.map((item) => item.id)),
    ).wait;
    return hosts.flatMap(
      (records) => adjustments.map((entries) {
        final hostsById = {for (final record in records) record.id: record};
        final byPayout = <String, List<PayoutAdjustment>>{};
        for (final entry in entries) {
          (byPayout[entry.payoutId] ??= []).add(entry);
        }
        return [
          for (final withdrawal in ready)
            _sheetRow(
              withdrawal,
              hostsById[withdrawal.hostId]?.hostDetails ?? const {},
              byPayout[withdrawal.id] ?? const [],
            ),
        ];
      }),
    );
  }

  static PayoutSheetRow _sheetRow(
    Withdrawal withdrawal,
    Map<String, dynamic> details,
    List<PayoutAdjustment> adjustments,
  ) {
    final sorted = [...adjustments]
      ..sort(
        (a, b) =>
            (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0)),
      );
    final periodEnd = withdrawal.periodEnd;
    // Credits made on the day a payout was moved to pending were carried to
    // the next cycle, so only credits up to the period's last day belong here.
    bool inPeriod(PayoutAdjustment entry) {
      final createdAt = entry.createdAt;
      if (periodEnd == null || createdAt == null) return true;
      final ist = createdAt.toUtc().add(_istOffset);
      return !DateTime(
        ist.year,
        ist.month,
        ist.day,
      ).isAfter(DateTime(periodEnd.year, periodEnd.month, periodEnd.day));
    }

    final bankAccount = withdrawal.bankAccount!;
    return PayoutSheetRow(
      withdrawal: withdrawal,
      bankAccount: bankAccount,
      beneficiaryId: PayoutBeneficiary.currentId(
        withdrawal.hostId,
        details,
        bankAccount,
      ),
      fullName: UserRecord.readText(details['fullName']),
      district: UserRecord.readText(details['district']),
      state: UserRecord.readText(details['state']),
      remarks: PayoutRemarks(
        credit: [
          for (final entry in sorted)
            if (entry.isCredit && inPeriod(entry)) entry.description,
        ],
        debit: [
          for (final entry in sorted)
            if (!entry.isCredit) entry.description,
        ],
      ),
    );
  }

  Either<Failure, List<Withdrawal>> _readyOnly(
    Either<Failure, List<Withdrawal>> found,
  ) => found.map(
    (items) => items
        .where((withdrawal) => !withdrawal.isOpen || withdrawal.hasBankAccount)
        .toList(),
  );

  Future<Either<Failure, PayoutBatchResult>> moveToPending(
    List<Withdrawal> withdrawals,
  ) => _runBatches(
    withdrawals,
    _dataSource.movePayoutsToPending,
    (withdrawal, result) =>
        withdrawal.markedPending(result.totalAmount, DateTime.now()),
  );

  Future<Either<Failure, PayoutBatchResult>> completePayouts(
    List<Withdrawal> withdrawals,
  ) => _runBatches(
    withdrawals,
    _dataSource.completePayouts,
    (withdrawal, result) => withdrawal.markedPaid(
      result.receipt ??
          PayoutReceipt(
            totalAmount: withdrawal.totalAmount,
            tdsPercent: PayoutSettings.tdsPercent,
            tdsAmount: withdrawal.tdsAmount(PayoutSettings.tdsPercent),
            receivableAmount: withdrawal.receivableAmount(
              PayoutSettings.tdsPercent,
            ),
          ),
      DateTime.now(),
    ),
  );

  Future<Either<Failure, PayoutBatchResult>> markFailed(
    List<Withdrawal> withdrawals,
    PayoutFailureInput failure,
  ) => _runBatches(
    withdrawals,
    (chunk) => _dataSource.failPayouts(chunk, failure),
    (withdrawal, result) => withdrawal.markedFailed(
      failure,
      result.failureCount ?? withdrawal.failureCount + 1,
      DateTime.now(),
    ),
  );

  Future<Either<Failure, PayoutBatchResult>> retryPayouts(
    List<Withdrawal> withdrawals,
  ) => _runBatches(
    withdrawals,
    _dataSource.retryPayouts,
    (withdrawal, _) => withdrawal.markedRetried(DateTime.now()),
  );

  Future<Either<Failure, PayoutBatchResult>> _runBatches(
    List<Withdrawal> withdrawals,
    Future<Either<Failure, List<PayoutItemResult>>> Function(
      List<Withdrawal> chunk,
    )
    send,
    Withdrawal Function(Withdrawal withdrawal, PayoutItemResult result) apply,
  ) async {
    var batch = const PayoutBatchResult();
    Failure? callFailure;
    var answered = false;
    for (var start = 0; start < withdrawals.length; start += _batchSize) {
      final chunk = withdrawals.sublist(
        start,
        min(start + _batchSize, withdrawals.length),
      );
      switch (await send(chunk)) {
        case Left(value: final failure):
          callFailure ??= failure;
          batch = batch.merge(
            PayoutBatchResult(
              failed: [
                for (final withdrawal in chunk)
                  PayoutFailure(withdrawal, failure.message),
              ],
            ),
          );
        case Right(value: final results):
          answered = true;
          final byId = {for (final result in results) result.payoutId: result};
          batch = batch.merge(
            PayoutBatchResult(
              succeeded: [
                for (final withdrawal in chunk)
                  if (byId[withdrawal.id] case final result? when result.ok)
                    apply(withdrawal, result),
              ],
              failed: [
                for (final withdrawal in chunk)
                  if (byId[withdrawal.id]?.ok != true)
                    PayoutFailure(
                      withdrawal,
                      byId[withdrawal.id]?.error ?? AppStrings.payoutFailed,
                    ),
              ],
            ),
          );
      }
    }
    final failure = callFailure;
    if (!answered && failure != null) return left(failure);
    return right(batch);
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
    Either<Failure, List<Withdrawal>> withdrawals,
  ) async {
    switch (withdrawals) {
      case Left(value: final failure):
        return left(failure);
      case Right(value: final list):
        final hostIds = {
          for (final item in list)
            if (!item.isPaid && item.hostId.isNotEmpty) item.hostId,
        };
        if (hostIds.isEmpty) return right(list);
        final accounts = await _dataSource.fetchApprovedBankAccounts(hostIds);
        return accounts.map(
          (byHost) => [
            for (final item in list)
              item.isPaid ? item : item.withBankAccount(byHost[item.hostId]),
          ],
        );
    }
  }

  static String? _pendingPayoutIdOf(UserRecord record) =>
      UserRecord.readText(record.hostDetails[Withdrawal.pendingPayoutIdField]);
}
