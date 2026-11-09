import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';

class UsersRemoteDataSource {
  const UsersRemoteDataSource(this._firestore);

  static const String _collection = 'users';
  static const String _roleField = 'role';
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

  Future<Either<Failure, List<UserRecord>>> fetchByRole(String role) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where(_roleField, isEqualTo: role)
          .get();
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

  Future<Either<Failure, Unit>> setBlocked(
    String id, {
    required bool blocked,
  }) => updateRecord(id, {_blockedField: blocked});

  Future<Either<Failure, Unit>> markDeletedByAdmin(String id) => updateRecord(
    id,
    {_deletedField: true, UserRecord.deletedByField: UserRecord.deletedByAdmin},
  );
}
