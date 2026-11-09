import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/firestore_failures.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/models/recharge_transaction.dart';

class RechargeRemoteDataSource {
  const RechargeRemoteDataSource(this._firestore);

  static const String _collection = 'transactions';

  final FirebaseFirestore _firestore;

  Future<Either<Failure, List<RechargeTransaction>>> fetchTransactions({
    DateTime? from,
    DateTime? until,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection(_collection);
    if (from != null) {
      query = query.where(
        RechargeTransaction.createdAtField,
        isGreaterThanOrEqualTo: Timestamp.fromDate(from),
      );
    }
    if (until != null) {
      query = query.where(
        RechargeTransaction.createdAtField,
        isLessThan: Timestamp.fromDate(until),
      );
    }

    try {
      final snapshot = await query
          .orderBy(RechargeTransaction.createdAtField, descending: true)
          .get();
      return right([
        for (final document in snapshot.docs)
          RechargeTransaction.fromDocument(document.id, document.data()),
      ]);
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.read(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }
}
