import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/firestore_failures.dart';
import 'package:zuno_admin_dashboard/core/data/record_page.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/models/recharge_transaction.dart';

class RechargeRemoteDataSource {
  const RechargeRemoteDataSource(this._firestore);

  static const String _collection = RechargeTransaction.collection;

  final FirebaseFirestore _firestore;

  Future<Either<Failure, RecordPage<RechargeTransaction>>> fetchPage({
    DateTime? from,
    DateTime? until,
    List<String>? statuses,
    List<String>? types,
    String? userId,
    String? field,
    Object? value,
    Object? cursor,
    required int pageSize,
  }) {
    Query<Map<String, dynamic>> base = _firestore.collection(_collection);
    if (userId != null) {
      base = base.where(RechargeTransaction.userIdField, isEqualTo: userId);
    }
    if (field != null) base = base.where(field, isEqualTo: value);
    if (statuses != null) {
      base = base.where(RechargeTransaction.statusField, whereIn: statuses);
    }
    if (types != null) {
      base = base.where(RechargeTransaction.typeField, whereIn: types);
    }
    return RecordPages.fetch(
      base,
      RecordPageQuery(from: from, until: until, cursor: cursor),
      RechargeTransaction.fromDocument,
      sortField: RechargeTransaction.createdAtField,
      pageSize: pageSize,
    );
  }

  Future<Either<Failure, RechargeTransaction?>> fetchById(String id) async {
    if (id.contains('/')) return right(null);
    try {
      final snapshot = await _firestore.collection(_collection).doc(id).get();
      final data = snapshot.data();
      return right(
        data == null ? null : RechargeTransaction.fromDocument(snapshot.id, data),
      );
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.read(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }

  Future<Either<Failure, RechargeTotals>> fetchTotals({
    DateTime? from,
    DateTime? until,
  }) async {
    Query<Map<String, dynamic>> completed(List<String> types) {
      var query = _firestore
          .collection(_collection)
          .where(
            RechargeTransaction.statusField,
            whereIn: RechargeTransaction.completedStatuses,
          )
          .where(RechargeTransaction.typeField, whereIn: types);
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
      return query;
    }

    const field = RechargeTransaction.totalAmountField;
    try {
      final results = await Future.wait([
        completed(
          RechargeTransaction.rechargeTypes,
        ).aggregate(count(), sum(field)).get(),
        completed(RechargeTransaction.creditTypes).aggregate(sum(field)).get(),
        completed(RechargeTransaction.debitTypes).aggregate(sum(field)).get(),
      ]);
      return right(
        RechargeTotals(
          rechargeCount: results[0].count ?? 0,
          rechargeAmount: results[0].getSum(field) ?? 0,
          creditAmount: results[1].getSum(field) ?? 0,
          debitAmount: results[2].getSum(field) ?? 0,
        ),
      );
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.read(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }

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
