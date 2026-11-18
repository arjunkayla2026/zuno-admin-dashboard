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
import 'package:zuno_admin_dashboard/core/utils/app_logger.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/bank_account_record.dart';
import 'package:zuno_admin_dashboard/features/host_details/data/models/admin_adjustment_totals.dart';
import 'package:zuno_admin_dashboard/features/host_details/data/models/host_earnings_totals.dart';
import 'package:zuno_admin_dashboard/features/host_details/data/models/wallet_transaction.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';

class HostEarningsRemoteDataSource {
  const HostEarningsRemoteDataSource(this._firestore, this._functions);

  static const String _adjustFunction = 'adjustHostEarnings';
  static const String _internalErrorCode = 'internal';
  static const String _creditType = 'credit';
  static const String _debitType = 'debit';

  static const String _usersCollection = 'users';
  static const String _ledgerAmountField = 'amount';

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  Query<Map<String, dynamic>> _payoutsOf(String hostId) => _firestore
      .collection(Withdrawal.collection)
      .where(Withdrawal.hostIdField, isEqualTo: hostId);

  String newRequestId() =>
      _firestore.collection(WalletTransaction.collection).doc().id;

  /// The host's payout records, newest first, without the ones forfeited
  /// when the account was deleted. The query is only `hostId` ordered by
  /// `createdAt`, which the deployed `hostId` + `createdAt` index serves;
  /// adding a `status` filter would need a `hostId` + `status` +
  /// `createdAt` index that does not exist, and Firestore would refuse the
  /// query. Forfeited records are dropped here instead (only deleted hosts
  /// have any), and pages keep loading until they fill.
  Future<Either<Failure, RecordPage<Withdrawal>>> fetchWithdrawalPage(
    String hostId, {
    Object? cursor,
  }) => RecordPages.untilMatch(
    cursor,
    (next) => RecordPages.fetch(
      _payoutsOf(hostId),
      RecordPageQuery(cursor: next),
      Withdrawal.fromDocument,
      sortField: Withdrawal.createdAtField,
    ),
    (batch) => batch.where((payout) => payout.isListed),
  );

  /// One count per listed status, the same `hostId` + `status` equality
  /// shape as [fetchTotals], so no composite index is needed.
  Future<Either<Failure, int>> countWithdrawals(String hostId) async {
    try {
      final counts = await Future.wait([
        for (final status in Withdrawal.listedStatuses)
          _payoutsOf(hostId)
              .where(Withdrawal.statusField, isEqualTo: status)
              .count()
              .get(),
      ]);
      return right(
        counts.fold(0, (total, snapshot) => total + (snapshot.count ?? 0)),
      );
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.read(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }

  /// The host's current `users` document, for the wallet balance and
  /// profile after the page opens or an adjustment changes them.
  Future<Either<Failure, UserRecord?>> fetchHostRecord(String hostId) async {
    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .doc(hostId)
          .get();
      final data = snapshot.data();
      return right(
        data == null ? null : UserRecord.fromDocument(snapshot.id, data),
      );
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.read(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }

  /// Payout totals for the Host Details cards: `totalAmount` (the withdraw
  /// amount, before TDS) of the host's `success` / `pending` / `open`
  /// `hostPayouts`. Total Revenue, the Available Wallet Amount and the admin
  /// credit / debit totals come from the host's `hostDetails.hostEarnings`
  /// instead (see `HostManagementRepository.toAdminHost`).
  Future<Either<Failure, HostEarningsTotals>> fetchTotals(String hostId) async {
    Future<double> statusSum(String status, String field) async {
      final result = await _payoutsOf(hostId)
          .where(Withdrawal.statusField, isEqualTo: status)
          .aggregate(sum(field))
          .get();
      return result.getSum(field) ?? 0;
    }

    try {
      final (paidTotal, pendingTotal, openTotal, deletion) = await (
        statusSum(Withdrawal.successStatus, Withdrawal.totalAmountField),
        statusSum(Withdrawal.pendingStatus, Withdrawal.totalAmountField),
        statusSum(Withdrawal.openStatus, Withdrawal.totalAmountField),
        _firestore.doc(DeletedAccountRecord.document).get(),
      ).wait;
      return right(
        HostEarningsTotals(
          paidTotal: paidTotal,
          pendingTotal: pendingTotal,
          openTotal: openTotal,
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

  /// Adds up the host's `host_admin_credit` / `host_admin_debit` `ledger`
  /// entries, which `adjustHostEarnings` writes for every adjustment (debits
  /// are stored negative). These are the Host Details credit / debit
  /// totals: complete for every host, old or new.
  ///
  /// It is the same query as the Wallet History tab (`uid`, `type` in,
  /// newest `createdAt` first), so it needs no other index or rule than
  /// that tab, and it adds the amounts up here. A host has few admin
  /// adjustments, so reading them all is cheap. Failures are logged with the
  /// Firestore error code.
  Future<Either<Failure, AdminAdjustmentTotals>> fetchLedgerAdjustments(
    String hostId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(WalletTransaction.collection)
          .where(WalletTransaction.uidField, isEqualTo: hostId)
          .where(
            WalletTransaction.typeField,
            whereIn: const [
              WalletTransaction.adminCreditType,
              WalletTransaction.adminDebitType,
            ],
          )
          .orderBy(WalletTransaction.createdAtField, descending: true)
          .get();
      var credit = 0.0;
      var debit = 0.0;
      for (final document in snapshot.docs) {
        final data = document.data();
        final value = data[_ledgerAmountField];
        final amount = value is num ? value.toDouble().abs() : 0.0;
        if (data[WalletTransaction.typeField] ==
            WalletTransaction.adminCreditType) {
          credit += amount;
        } else {
          debit += amount;
        }
      }
      return right(AdminAdjustmentTotals(credit: credit, debit: debit));
    } on FirebaseException catch (error, stackTrace) {
      AppLogger.error(
        '✖ hostEarnings.ledgerAdjustments ${error.code} ${error.message}',
        error,
        stackTrace,
      );
      return left(FirestoreFailures.read(error.code));
    } catch (error, stackTrace) {
      AppLogger.error(
        '✖ hostEarnings.ledgerAdjustments $error',
        error,
        stackTrace,
      );
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
