import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';

class UsersRemoteDataSource {
  const UsersRemoteDataSource(this._firestore);

  static const String _collection = 'users';
  static const String _roleField = 'role';
  static const String _hostStatusField = 'hostDetails.hostStatus';
  static const String _updatedAtField = 'updatedAt';
  static const String _blockedField = 'isAccountBlocked';
  static const String _deletedField = 'isAccountDeleted';

  final FirebaseFirestore _firestore;

  static DataFailure failureForCode(String code) => DataFailure(switch (code) {
    'permission-denied' || 'unauthenticated' => AppStrings.recordsAccessDenied,
    'unavailable' || 'deadline-exceeded' => AppStrings.recordsNetworkError,
    _ => AppStrings.recordsLoadFailed,
  });

  static DataFailure writeFailureForCode(String code) => DataFailure(
    switch (code) {
      'permission-denied' || 'unauthenticated' => AppStrings.recordsWriteDenied,
      'not-found' => AppStrings.recordNotFound,
      'unavailable' || 'deadline-exceeded' => AppStrings.recordsNetworkError,
      _ => AppStrings.recordsSaveFailed,
    },
  );

  static int newestFirst(UserRecord a, UserRecord b) {
    final first = a.createdAt;
    final second = b.createdAt;
    if (first == null && second == null) return a.id.compareTo(b.id);
    if (first == null) return 1;
    if (second == null) return -1;
    return second.compareTo(first);
  }

  Future<Either<Failure, List<UserRecord>>> fetchByRole(String role) => _fetch(
    _firestore.collection(_collection).where(_roleField, isEqualTo: role),
  );

  Future<Either<Failure, List<UserRecord>>> fetchHostApplicants() => _fetch(
    _firestore
        .collection(_collection)
        .where(_hostStatusField, isEqualTo: UserRecord.documentSubmitted),
  );

  Future<Either<Failure, List<UserRecord>>> _fetch(
    Query<Map<String, dynamic>> query,
  ) async {
    try {
      final snapshot = await query.get();
      final records = [
        for (final document in snapshot.docs)
          UserRecord.fromDocument(document.id, document.data()),
      ]..sort(newestFirst);
      return right(records);
    } on FirebaseException catch (error) {
      return left(failureForCode(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }

  Future<Either<Failure, Unit>> updateRecord(
    String id,
    Map<String, Object?> fields,
  ) async {
    if (fields.isEmpty) return right(unit);
    try {
      await _firestore.collection(_collection).doc(id).update({
        ...fields,
        _updatedAtField: FieldValue.serverTimestamp(),
      });
      return right(unit);
    } on FirebaseException catch (error) {
      return left(writeFailureForCode(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsSaveFailed));
    }
  }

  Future<Either<Failure, Unit>> reviewHostDocument(
    String id, {
    required String document,
    required String status,
  }) => _transact(
    id,
    (data) =>
        UserRecord.hostDocumentReview(data, document: document, status: status),
    refusedMessage: AppStrings.documentAlreadyReviewed,
  );

  Future<Either<Failure, Unit>> decideHostRequest(
    String id, {
    required bool approved,
  }) => _transact(
    id,
    (data) => UserRecord.hostRequestDecision(data, approved: approved),
    refusedMessage: AppStrings.hostRequestNotReady,
  );

  Future<Either<Failure, Unit>> _transact(
    String id,
    Map<String, Object?>? Function(Map<String, dynamic> data) buildUpdate, {
    required String refusedMessage,
  }) async {
    final reference = _firestore.collection(_collection).doc(id);
    Failure? refused;
    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(reference);
        final data = snapshot.data();
        final update = data == null ? null : buildUpdate(data);
        if (update == null) {
          refused = DataFailure(
            data == null ? AppStrings.recordNotFound : refusedMessage,
          );
          return;
        }
        transaction.update(reference, {
          ...update,
          _updatedAtField: FieldValue.serverTimestamp(),
        });
      });
    } on FirebaseException catch (error) {
      return left(writeFailureForCode(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsSaveFailed));
    }
    final failure = refused;
    return failure == null ? right(unit) : left(failure);
  }

  Future<Either<Failure, Unit>> setBlocked(
    String id, {
    required bool blocked,
  }) => updateRecord(id, {_blockedField: blocked});

  Future<Either<Failure, Unit>> markDeletedByAdmin(String id) => updateRecord(
    id,
    {_deletedField: true, UserRecord.deletedByField: UserRecord.deletedByAdmin},
  );
}
