import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/firestore_failures.dart';
import 'package:zuno_admin_dashboard/core/data/payout_settings.dart';
import 'package:zuno_admin_dashboard/core/data/record_page.dart';
import 'package:zuno_admin_dashboard/core/data/search_keywords.dart';
import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/core/data/user_search.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/bank_account_record.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/payout_batch_result.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/payout_summary.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';

class PaymentRemoteDataSource {
  const PaymentRemoteDataSource(this._firestore, this._functions);

  static const String _settingsCollection = 'settings';
  static const String _appDocument = 'app';
  static const String _moveFunction = 'movePayoutsToPending';
  static const String _completeFunction = 'completeHostPayouts';
  static const String _internalErrorCode = 'internal';
  static const int _idsPerQuery = 30;
  static const int _paidSearchLimit = 50;
  static const int _snapshotSearchLimit = 50;
  static const Duration _batchTimeout = Duration(minutes: 5);

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>> get _payouts =>
      _firestore.collection(Withdrawal.collection);

  static String get _withdrawableTotal =>
      Withdrawal.withdrawablePath(Withdrawal.totalAmountField);

  Query<Map<String, dynamic>> _open(double? minimum) => _payouts
      .where(Withdrawal.statusField, isEqualTo: Withdrawal.openStatus)
      .where(Withdrawal.bankReadyField, isEqualTo: true)
      .where(
        _withdrawableTotal,
        isGreaterThanOrEqualTo: PayoutSettings.eligibleFrom(minimum),
      );

  Query<Map<String, dynamic>> get _pending => _payouts.where(
    Withdrawal.statusField,
    isEqualTo: Withdrawal.pendingStatus,
  );

  Query<Map<String, dynamic>> get _paid => _payouts.where(
    Withdrawal.statusField,
    isEqualTo: Withdrawal.successStatus,
  );

  Future<Either<Failure, double?>> fetchMinimumPayout() async {
    try {
      final snapshot = await _firestore
          .collection(_settingsCollection)
          .doc(_appDocument)
          .get();
      return right(
        PayoutSettings.readMinimum(
          snapshot.data()?[PayoutSettings.minimumPayoutField],
        ),
      );
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.read(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }

  Future<Either<Failure, RecordPage<Withdrawal>>> fetchOpenPage({
    required double? minimum,
    Object? cursor,
  }) => RecordPages.fetch(
    _open(minimum),
    RecordPageQuery(cursor: cursor),
    Withdrawal.fromDocument,
    sortField: _withdrawableTotal,
  );

  Future<Either<Failure, RecordPage<Withdrawal>>> fetchPendingPage({
    Object? cursor,
  }) => RecordPages.fetch(
    _pending,
    RecordPageQuery(cursor: cursor),
    Withdrawal.fromDocument,
    sortField: Withdrawal.updatedAtField,
  );

  Future<Either<Failure, RecordPage<Withdrawal>>> fetchPaidPage({
    Object? cursor,
  }) => RecordPages.fetch(
    _paid,
    RecordPageQuery(cursor: cursor),
    Withdrawal.fromDocument,
    sortField: Withdrawal.paidAtField,
  );

  Future<Either<Failure, List<Withdrawal>>> fetchAllOpen(
    double? minimum, {
    required int limit,
  }) => _fetchAll(
    _open(minimum).orderBy(_withdrawableTotal, descending: true),
    limit,
  );

  Future<Either<Failure, List<Withdrawal>>> fetchAllPending({
    required int limit,
  }) => _fetchAll(
    _pending.orderBy(Withdrawal.updatedAtField, descending: true),
    limit,
  );

  Future<Either<Failure, PayoutSummary>> fetchOpenSummary(
    double? minimum,
  ) async {
    final earnedField = Withdrawal.withdrawablePath(
      Withdrawal.callEarningsField,
    );
    final secondsField = Withdrawal.withdrawablePath(
      Withdrawal.callDurationField,
    );
    final totalField = _withdrawableTotal;
    try {
      final result = await _open(minimum)
          .aggregate(
            count(),
            sum(earnedField),
            sum(secondsField),
            sum(totalField),
          )
          .get();
      return right(
        PayoutSummary(
          hostCount: result.count ?? 0,
          amountEarned: result.getSum(earnedField) ?? 0,
          callSeconds: (result.getSum(secondsField) ?? 0).round(),
          totalAmount: result.getSum(totalField) ?? 0,
        ),
      );
    } on FirebaseException catch (error) {
      debugPrint('Payout summary failed [${error.code}]: ${error.message}');
      return left(FirestoreFailures.read(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }

  Future<Either<Failure, int>> countPending() => _count(_pending);

  Future<Either<Failure, int>> countPaid() => _count(_paid);

  Future<Either<Failure, List<Withdrawal>>> fetchByIds(Iterable<String> ids) =>
      _whereIn(
        ids,
        (batch) => _payouts.where(FieldPath.documentId, whereIn: batch),
      );

  Future<Either<Failure, List<Withdrawal>>> fetchPendingForHosts(
    Iterable<String> hostIds,
  ) => _whereIn(
    hostIds,
    (batch) => _pending.where(Withdrawal.hostIdField, whereIn: batch),
  );

  Future<Either<Failure, List<Withdrawal>>> fetchPaidForHosts(
    Iterable<String> hostIds,
  ) => _whereIn(
    hostIds,
    (batch) => _paid
        .where(Withdrawal.hostIdField, whereIn: batch)
        .orderBy(Withdrawal.paidAtField, descending: true)
        .limit(_paidSearchLimit),
  );

  Future<Either<Failure, List<Withdrawal>>> searchBySnapshot(
    String term,
  ) async {
    final upper = term.toUpperCase();
    final namePrefixes = {
      term,
      term.toLowerCase(),
      '${term[0].toUpperCase()}${term.substring(1)}',
    };
    Query<Map<String, dynamic>> startsWith(String field, String prefix) =>
        _payouts
            .where(field, isGreaterThanOrEqualTo: prefix)
            .where(field, isLessThan: '$prefix${UserSearch.prefixEnd}')
            .limit(_snapshotSearchLimit);
    try {
      final snapshots = await Future.wait([
        for (final prefix in namePrefixes)
          startsWith(Withdrawal.hostNameField, prefix).get(),
        if (!term.contains(' '))
          startsWith(Withdrawal.hostUserIdField, upper).get(),
      ]);
      return right(
        {
          for (final snapshot in snapshots)
            for (final document in snapshot.docs)
              document.id: Withdrawal.fromDocument(
                document.id,
                document.data(),
              ),
        }.values.toList(),
      );
    } on FirebaseException catch (error) {
      debugPrint('Payout search failed [${error.code}]: ${error.message}');
      return left(FirestoreFailures.read(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }

  Future<Either<Failure, List<Withdrawal>>> fetchByWithdrawId(
    String withdrawId,
  ) => _fetchAll(
    _payouts.where(Withdrawal.withdrawIdField, isEqualTo: withdrawId),
    1,
  );

  Future<Either<Failure, Map<String, PayoutBankAccount>>>
  fetchApprovedBankAccounts(Iterable<String> hostIds) async {
    final ids = hostIds.toSet().toList();
    try {
      final snapshots = await Future.wait([
        for (var start = 0; start < ids.length; start += _idsPerQuery)
          _firestore
              .collection(SearchKeywords.bankAccountsCollection)
              .where(
                FieldPath.documentId,
                whereIn: ids.sublist(
                  start,
                  (start + _idsPerQuery).clamp(0, ids.length),
                ),
              )
              .get(),
      ]);
      return right({
        for (final snapshot in snapshots)
          for (final document in snapshot.docs)
            if (document.data()[BankAccountRecord.statusField] ==
                UserRecord.documentApproved)
              document.id: ?PayoutBankAccount.fromMap(document.data()),
      });
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.read(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }

  Future<Either<Failure, List<PayoutItemResult>>> movePayoutsToPending(
    List<Withdrawal> withdrawals,
  ) => _callBatch(_moveFunction, [
    for (final withdrawal in withdrawals)
      {'payoutId': withdrawal.id, 'expectedAmount': withdrawal.totalAmount},
  ]);

  Future<Either<Failure, List<PayoutItemResult>>> completePayouts(
    List<Withdrawal> withdrawals,
  ) => _callBatch(_completeFunction, [
    for (final withdrawal in withdrawals)
      {
        'payoutId': withdrawal.id,
        'expectedTotalAmount': withdrawal.totalAmount,
      },
  ]);

  Future<Either<Failure, List<PayoutItemResult>>> _callBatch(
    String function,
    List<Map<String, Object>> items,
  ) async {
    try {
      final response = await _functions
          .httpsCallable(
            function,
            options: HttpsCallableOptions(timeout: _batchTimeout),
          )
          .call<Map<Object?, Object?>>({'items': items});
      final results = response.data['results'];
      return right([
        if (results is List)
          for (final result in results) ?PayoutItemResult.fromMap(result),
      ]);
    } on FirebaseFunctionsException catch (error) {
      final message = error.message;
      return left(
        DataFailure(
          message == null || error.code == _internalErrorCode
              ? AppStrings.payoutFailed
              : message,
        ),
      );
    } catch (_) {
      return left(const DataFailure(AppStrings.payoutFailed));
    }
  }

  Future<Either<Failure, int>> _count(Query<Map<String, dynamic>> query) async {
    try {
      final snapshot = await query.count().get();
      return right(snapshot.count ?? 0);
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.read(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }

  Future<Either<Failure, List<Withdrawal>>> _fetchAll(
    Query<Map<String, dynamic>> query,
    int limit,
  ) async {
    try {
      final snapshot = await query.limit(limit).get();
      return right([
        for (final document in snapshot.docs)
          Withdrawal.fromDocument(document.id, document.data()),
      ]);
    } on FirebaseException catch (error) {
      debugPrint('Payout lookup failed [${error.code}]: ${error.message}');
      return left(FirestoreFailures.read(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }

  Future<Either<Failure, List<Withdrawal>>> _whereIn(
    Iterable<String> values,
    Query<Map<String, dynamic>> Function(List<String> batch) query,
  ) async {
    final ids = values.where((id) => id.isNotEmpty).toSet().toList();
    try {
      final snapshots = await Future.wait([
        for (var start = 0; start < ids.length; start += _idsPerQuery)
          query(ids.sublist(start, (start + _idsPerQuery).clamp(0, ids.length)))
              .get(),
      ]);
      return right([
        for (final snapshot in snapshots)
          for (final document in snapshot.docs)
            Withdrawal.fromDocument(document.id, document.data()),
      ]);
    } on FirebaseException catch (error) {
      debugPrint('Payout lookup failed [${error.code}]: ${error.message}');
      return left(FirestoreFailures.read(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }
}
