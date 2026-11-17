import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/deleted_account_record.dart';
import 'package:zuno_admin_dashboard/core/data/firestore_failures.dart';
import 'package:zuno_admin_dashboard/core/data/record_page.dart';
import 'package:zuno_admin_dashboard/core/data/search_keywords.dart';
import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/bank_account_record.dart';
import 'package:zuno_admin_dashboard/features/host_details/data/models/host_earnings_totals.dart';
import 'package:zuno_admin_dashboard/features/host_details/data/models/wallet_transaction.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';

class HostEarningsRemoteDataSource {
  const HostEarningsRemoteDataSource(this._firestore, this._functions);

  static const String _adjustFunction = 'adjustHostEarnings';
  static const String _internalErrorCode = 'internal';
  static const String _creditType = 'credit';
  static const String _debitType = 'debit';
  static const String _adminCreditField = 'adminCreditAmount';
  static const String _adminDebitField = 'adminDebitAmount';

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  Query<Map<String, dynamic>> _payoutsOf(String hostId) => _firestore
      .collection(Withdrawal.collection)
      .where(Withdrawal.hostIdField, isEqualTo: hostId);

  Query<Map<String, dynamic>> _listedPayoutsOf(String hostId) =>
      _payoutsOf(hostId)
          .where(Withdrawal.statusField, whereIn: Withdrawal.listedStatuses);

  String newRequestId() =>
      _firestore.collection(WalletTransaction.collection).doc().id;

  Future<Either<Failure, RecordPage<Withdrawal>>> fetchWithdrawalPage(
    String hostId, {
    Object? cursor,
  }) => RecordPages.fetch(
    _listedPayoutsOf(hostId),
    RecordPageQuery(cursor: cursor),
    Withdrawal.fromDocument,
    sortField: Withdrawal.createdAtField,
  );

  Future<Either<Failure, int>> countWithdrawals(String hostId) async {
    try {
      final snapshot = await _listedPayoutsOf(hostId).count().get();
      return right(snapshot.count ?? 0);
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.read(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }

  Future<Either<Failure, HostEarningsTotals>> fetchTotals(String hostId) async {
    const totalField = Withdrawal.totalAmountField;
    Future<double> statusTotal(String status) async {
      final result = await _payoutsOf(hostId)
          .where(Withdrawal.statusField, isEqualTo: status)
          .aggregate(sum(totalField))
          .get();
      return result.getSum(totalField) ?? 0;
    }

    try {
      final (all, paidTotal, pendingTotal, openTotal, deletion) = await (
        _payoutsOf(hostId)
            .aggregate(sum(_adminCreditField), sum(_adminDebitField))
            .get(),
        statusTotal(Withdrawal.successStatus),
        statusTotal(Withdrawal.pendingStatus),
        statusTotal(Withdrawal.openStatus),
        _firestore.doc(DeletedAccountRecord.document).get(),
      ).wait;
      return right(
        HostEarningsTotals(
          paidTotal: paidTotal,
          pendingTotal: pendingTotal,
          openTotal: openTotal,
          adminCredit: all.getSum(_adminCreditField) ?? 0,
          adminDebit: all.getSum(_adminDebitField) ?? 0,
          deletedAccountProfit:
              DeletedAccountRecord.incomeOf(deletion.data(), hostId) ??
              openTotal + pendingTotal,
        ),
      );
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.read(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }

  Future<Either<Failure, PayoutBankAccount?>> fetchApprovedBankAccount(
    String hostId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(SearchKeywords.bankAccountsCollection)
          .doc(hostId)
          .get();
      final data = snapshot.data();
      return right(
        data?[BankAccountRecord.statusField] == UserRecord.documentApproved
            ? PayoutBankAccount.fromMap(data)
            : null,
      );
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.read(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }

  Future<Either<Failure, RecordPage<WalletTransaction>>> fetchWalletPage(
    String hostId, {
    required List<String> types,
    Object? cursor,
  }) => RecordPages.fetch(
    _firestore
        .collection(WalletTransaction.collection)
        .where(WalletTransaction.uidField, isEqualTo: hostId)
        .where(WalletTransaction.typeField, whereIn: types),
    RecordPageQuery(cursor: cursor),
    WalletTransaction.fromLedger,
    sortField: WalletTransaction.createdAtField,
  );

  Future<Either<Failure, Unit>> adjust({
    required String hostId,
    required bool isCredit,
    required int amount,
    required String description,
    required String requestId,
  }) async {
    try {
      await _functions.httpsCallable(_adjustFunction).call<Object?>({
        'hostId': hostId,
        'type': isCredit ? _creditType : _debitType,
        'amount': amount,
        'description': description,
        'requestId': requestId,
      });
      return right(unit);
    } on FirebaseFunctionsException catch (error) {
      final message = error.message;
      return left(
        DataFailure(
          message == null || error.code == _internalErrorCode
              ? AppStrings.hostAdjustmentFailed
              : message,
        ),
      );
    } catch (_) {
      return left(const DataFailure(AppStrings.hostAdjustmentFailed));
    }
  }
}
