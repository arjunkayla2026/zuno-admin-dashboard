import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/firestore_failures.dart';
import 'package:zuno_admin_dashboard/core/data/payout_settings.dart';
import 'package:zuno_admin_dashboard/core/data/record_page.dart';
import 'package:zuno_admin_dashboard/core/data/search_keywords.dart';
import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/bank_account_record.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/payout_summary.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';

class PaymentRemoteDataSource {
  const PaymentRemoteDataSource(this._firestore, this._functions);

  static const String _settingsCollection = 'settings';
  static const String _appDocument = 'app';
  static const String _completePayoutFunction = 'completeHostPayout';
  static const String _internalErrorCode = 'internal';
  static const int _idsPerQuery = 30;
  static const int _paidSearchLimit = 50;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>> get _payouts =>
      _firestore.collection(Withdrawal.collection);

  Query<Map<String, dynamic>> _eligible(double? minimum) => _payouts
      .where(Withdrawal.statusField, isEqualTo: Withdrawal.pendingStatus)
      .where(
        Withdrawal.totalAmountField,
        isGreaterThanOrEqualTo: PayoutSettings.eligibleFrom(minimum),
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

  Future<Either<Failure, RecordPage<Withdrawal>>> fetchEligiblePage({
    required double? minimum,
    Object? cursor,
    int pageSize = RecordPageQuery.pageSize,
  }) => RecordPages.fetch(
    _eligible(minimum),
    RecordPageQuery(cursor: cursor),
    Withdrawal.fromDocument,
    sortField: Withdrawal.totalAmountField,
    pageSize: pageSize,
  );

  Future<Either<Failure, RecordPage<Withdrawal>>> fetchPaidPage({
    Object? cursor,
    int pageSize = RecordPageQuery.pageSize,
  }) => RecordPages.fetch(
    _paid,
    RecordPageQuery(cursor: cursor),
    Withdrawal.fromDocument,
    sortField: Withdrawal.paidAtField,
    pageSize: pageSize,
  );

  Future<Either<Failure, PayoutSummary>> fetchEligibleSummary(
    double? minimum,
  ) async {
    const earnedField = Withdrawal.callEarningsField;
    const secondsField = Withdrawal.callDurationField;
    const totalField = Withdrawal.totalAmountField;
    try {
      final result = await _eligible(minimum)
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
          amountEarned: NumberFormatter.roundAmount(
            result.getSum(earnedField) ?? 0,
          ),
          callSeconds: (result.getSum(secondsField) ?? 0).round(),
          totalAmount: NumberFormatter.roundAmount(
            result.getSum(totalField) ?? 0,
          ),
        ),
      );
    } on FirebaseException catch (error) {
      debugPrint('Payout summary failed [${error.code}]: ${error.message}');
      return left(FirestoreFailures.read(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }

  Future<Either<Failure, int>> countPaid() async {
    try {
      final snapshot = await _paid.count().get();
      return right(snapshot.count ?? 0);
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.read(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }

  Future<Either<Failure, List<Withdrawal>>> fetchByIds(Iterable<String> ids) =>
      _whereIn(
        ids,
        (batch) => _payouts.where(FieldPath.documentId, whereIn: batch),
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

  Future<Either<Failure, List<Withdrawal>>> fetchByWithdrawId(
    String withdrawId,
  ) async {
    try {
      final snapshot = await _payouts
          .where(Withdrawal.withdrawIdField, isEqualTo: withdrawId)
          .limit(1)
          .get();
      return right([
        for (final document in snapshot.docs)
          Withdrawal.fromDocument(document.id, document.data()),
      ]);
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.read(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }

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

  Future<Either<Failure, PayoutReceipt>> completePayout({
    required String payoutId,
    required double expectedTotalAmount,
  }) async {
    try {
      final response = await _functions
          .httpsCallable(_completePayoutFunction)
          .call<Map<Object?, Object?>>({
            'payoutId': payoutId,
            'expectedTotalAmount': expectedTotalAmount,
          });
      return right(PayoutReceipt.fromMap(response.data));
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
