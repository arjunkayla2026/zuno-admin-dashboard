import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/firestore_failures.dart';
import 'package:zuno_admin_dashboard/core/data/payout_settings.dart';
import 'package:zuno_admin_dashboard/core/data/record_page.dart';
import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/core/data/user_search.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/bank_account_record.dart';
import 'package:zuno_admin_dashboard/features/host_details/data/models/wallet_transaction.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/payout_batch_result.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/payout_beneficiary.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/payout_failure_reason.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/payout_sheet_row.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';

class PaymentRemoteDataSource {
  const PaymentRemoteDataSource(this._firestore, this._functions);

  static const String _settingsCollection = 'settings';
  static const String _appDocument = 'app';
  static const String _moveFunction = 'movePayoutsToPending';
  static const String _completeFunction = 'completeHostPayouts';
  static const String _failFunction = 'failHostPayouts';
  static const String _retryFunction = 'retryHostPayouts';
  static const String _internalErrorCode = 'internal';
  static const String _payoutIdField = 'payoutId';
  static const String _usersCollection = 'users';
  static const String _hostDetailsField = 'hostDetails';
  static const int _beneficiariesPerTransaction = 100;
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

  Query<Map<String, dynamic>> get _failed => _payouts.where(
    Withdrawal.statusField,
    isEqualTo: Withdrawal.failedStatus,
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
    DateTime? from,
    DateTime? until,
  }) => RecordPages.fetch(
    _paid,
    RecordPageQuery(cursor: cursor, from: from, until: until),
    Withdrawal.fromDocument,
    sortField: Withdrawal.paidAtField,
  );

  Future<Either<Failure, RecordPage<Withdrawal>>> fetchFailedPage({
    Object? cursor,
  }) => RecordPages.fetch(
    _failed,
    RecordPageQuery(cursor: cursor),
    Withdrawal.fromDocument,
    sortField: Withdrawal.updatedAtField,
  );

  Future<Either<Failure, List<Withdrawal>>> fetchAllFailed({
    required int limit,
  }) => _fetchAll(
    _failed.orderBy(Withdrawal.updatedAtField, descending: true),
    limit,
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

  Future<Either<Failure, int>> countPending() => _count(_pending);

  Future<Either<Failure, int>> countPaid({DateTime? from, DateTime? until}) =>
      _count(
        from == null && until == null
            ? _paid
            : _paidBetween(
                _paid,
                from,
                until,
              ).orderBy(Withdrawal.paidAtField, descending: true),
      );

  static Query<Map<String, dynamic>> _paidBetween(
    Query<Map<String, dynamic>> query,
    DateTime? from,
    DateTime? until,
  ) {
    var filtered = query;
    if (from != null) {
      filtered = filtered.where(
        Withdrawal.paidAtField,
        isGreaterThanOrEqualTo: Timestamp.fromDate(from),
      );
    }
    if (until != null) {
      filtered = filtered.where(
        Withdrawal.paidAtField,
        isLessThan: Timestamp.fromDate(until),
      );
    }
    return filtered;
  }

  Future<Either<Failure, int>> countFailed() => _count(_failed);

  Future<Either<Failure, List<Withdrawal>>> fetchFailedForHosts(
    Iterable<String> hostIds,
  ) => _whereIn(
    hostIds,
    (batch) => _failed.where(Withdrawal.hostIdField, whereIn: batch),
  );

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
    Iterable<String> hostIds, {
    DateTime? from,
    DateTime? until,
  }) => _whereIn(
    hostIds,
    (batch) => _paidBetween(
      _paid.where(Withdrawal.hostIdField, whereIn: batch),
      from,
      until,
    ).orderBy(Withdrawal.paidAtField, descending: true).limit(_paidSearchLimit),
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
              .collection(BankAccountRecord.collection)
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

  /// Admin credit and debit ledger entries written against [payoutIds].
  Future<Either<Failure, List<PayoutAdjustment>>> fetchAdjustments(
    Iterable<String> payoutIds,
  ) async {
    final ids = payoutIds.where((id) => id.isNotEmpty).toSet().toList();
    try {
      final snapshots = await Future.wait([
        for (var start = 0; start < ids.length; start += _idsPerQuery)
          _firestore
              .collection(WalletTransaction.collection)
              .where(
                _payoutIdField,
                whereIn: ids.sublist(
                  start,
                  (start + _idsPerQuery).clamp(0, ids.length),
                ),
              )
              .get(),
      ]);
      return right([
        for (final snapshot in snapshots)
          for (final document in snapshot.docs)
            ?PayoutAdjustment.fromLedger(document.data()),
      ]);
    } on FirebaseException catch (error) {
      debugPrint('Payout remarks failed [${error.code}]: ${error.message}');
      return left(FirestoreFailures.read(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }

  /// Makes sure every host in [bankHashByHost] has `hostDetails.beneficiaryId`
  /// for its current bank account and `hostDetails.isBeneficiary` true,
  /// creating a new ID only when there is none or the account changed.
  /// Returns each host's beneficiary ID; hosts without a user document are
  /// left out.
  Future<Either<Failure, Map<String, String>>> registerBeneficiaries(
    Map<String, String> bankHashByHost,
  ) async {
    final hostIds = bankHashByHost.keys.where((id) => id.isNotEmpty).toList();
    final registered = <String, String>{};
    String field(String name) => '$_hostDetailsField.$name';
    try {
      for (
        var start = 0;
        start < hostIds.length;
        start += _beneficiariesPerTransaction
      ) {
        final chunk = hostIds.sublist(
          start,
          (start + _beneficiariesPerTransaction).clamp(0, hostIds.length),
        );
        final chunkIds = await _firestore.runTransaction((transaction) async {
          final references = [
            for (final id in chunk)
              _firestore.collection(_usersCollection).doc(id),
          ];
          final snapshots = await Future.wait(references.map(transaction.get));
          final ids = <String, String>{};
          for (var index = 0; index < snapshots.length; index++) {
            final snapshot = snapshots[index];
            final data = snapshot.data();
            if (data == null) continue;
            final details = data[_hostDetailsField] is Map
                ? Map<String, dynamic>.from(data[_hostDetailsField] as Map)
                : <String, dynamic>{};
            final bankHash = bankHashByHost[snapshot.id]!;
            final storedId = UserRecord.readText(
              details[PayoutBeneficiary.idField],
            );
            final sameAccount =
                storedId != null &&
                details[PayoutBeneficiary.bankHashField] == bankHash;
            final id = sameAccount ? storedId : PayoutBeneficiary.generateId();
            if (!sameAccount ||
                details[PayoutBeneficiary.isBeneficiaryField] != true) {
              transaction.update(references[index], {
                field(PayoutBeneficiary.idField): id,
                field(PayoutBeneficiary.isBeneficiaryField): true,
                field(PayoutBeneficiary.bankHashField): bankHash,
                field(PayoutBeneficiary.updatedAtField):
                    FieldValue.serverTimestamp(),
              });
            }
            ids[snapshot.id] = id;
          }
          return ids;
        });
        registered.addAll(chunkIds);
      }
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.write(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsSaveFailed));
    }
    return right(registered);
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

  Future<Either<Failure, List<PayoutItemResult>>> failPayouts(
    List<Withdrawal> withdrawals,
    PayoutFailureInput failure,
  ) => _callBatch(
    _failFunction,
    _expectedTotals(withdrawals),
    extra: {'reason': failure.reason.value, 'note': ?failure.note},
  );

  Future<Either<Failure, List<PayoutItemResult>>> retryPayouts(
    List<Withdrawal> withdrawals,
  ) => _callBatch(_retryFunction, _expectedTotals(withdrawals));

  static List<Map<String, Object>> _expectedTotals(
    List<Withdrawal> withdrawals,
  ) => [
    for (final withdrawal in withdrawals)
      {
        'payoutId': withdrawal.id,
        'expectedTotalAmount': withdrawal.totalAmount,
      },
  ];

  Future<Either<Failure, List<PayoutItemResult>>> _callBatch(
    String function,
    List<Map<String, Object>> items, {
    Map<String, Object> extra = const {},
  }) async {
    try {
      final response = await _functions
          .httpsCallable(
            function,
            options: HttpsCallableOptions(timeout: _batchTimeout),
          )
          .call<Map<Object?, Object?>>({'items': items, ...extra});
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
