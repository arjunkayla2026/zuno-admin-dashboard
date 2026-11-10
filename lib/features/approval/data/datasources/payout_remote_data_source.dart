import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/firestore_failures.dart';
import 'package:zuno_admin_dashboard/core/data/record_page.dart';
import 'package:zuno_admin_dashboard/core/data/search_keywords.dart';
import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/bank_account_record.dart';

class PayoutRemoteDataSource {
  const PayoutRemoteDataSource(this._firestore, this._auth);

  static const String _collection = SearchKeywords.bankAccountsCollection;
  static const String _updatedAtField = 'updatedAt';

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Query<Map<String, dynamic>> get _submitted => _firestore
      .collection(_collection)
      .where(
        BankAccountRecord.statusField,
        isEqualTo: UserRecord.documentSubmitted,
      );

  Future<Either<Failure, RecordPage<BankAccountRecord>>> fetchSubmitted(
    RecordPageQuery query,
  ) => RecordPages.fetch(_submitted, query, BankAccountRecord.fromDocument);

  Future<Either<Failure, int>> countSubmitted(RecordPageQuery query) =>
      RecordPages.count(_submitted, query);

  Future<Either<Failure, Unit>> decide(
    String id, {
    required bool approved,
    required String reviewedAccountNumber,
    required String reviewedIfscCode,
  }) async {
    final adminUid = _auth.currentUser?.uid;
    if (adminUid == null) {
      return left(const DataFailure(AppStrings.recordsWriteDenied));
    }

    final reference = _firestore.collection(_collection).doc(id);
    Failure? refused;
    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(reference);
        final data = snapshot.data();
        final update = data == null
            ? null
            : BankAccountRecord.decision(
                data,
                approved: approved,
                reviewedAccountNumber: reviewedAccountNumber,
                reviewedIfscCode: reviewedIfscCode,
                adminUid: adminUid,
              );
        if (update == null) {
          refused = DataFailure(
            data == null ? AppStrings.recordNotFound : AppStrings.payoutChanged,
          );
          return;
        }
        transaction.update(reference, {
          ...update,
          _updatedAtField: FieldValue.serverTimestamp(),
        });
      });
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.write(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsSaveFailed));
    }
    final failure = refused;
    return failure == null ? right(unit) : left(failure);
  }
}
