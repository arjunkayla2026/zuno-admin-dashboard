import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/firestore_failures.dart';
import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';

/// Withdrawal Workflow Testing: the calling app's staging-only
/// `seedMockWithdrawals` / `resetMockWithdrawals` callables, and reads of
/// the `users` and `hostPayouts` documents they flag `isMock`.
class MockWithdrawalsRemoteDataSource {
  const MockWithdrawalsRemoteDataSource(this._firestore, this._functions);

  static const String _seedFunction = 'seedMockWithdrawals';
  static const String _resetFunction = 'resetMockWithdrawals';
  static const String _usersCollection = 'users';
  static const String _internalErrorCode = 'internal';

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  Future<Either<Failure, Map<Object?, Object?>>> seed() => _call(_seedFunction);

  Future<Either<Failure, Map<Object?, Object?>>> reset() =>
      _call(_resetFunction);

  Future<Either<Failure, List<UserRecord>>> fetchMockHosts() => _read(
    _firestore
        .collection(_usersCollection)
        .where(Withdrawal.isMockField, isEqualTo: true),
    UserRecord.fromDocument,
  );

  Future<Either<Failure, List<Withdrawal>>> fetchMockPayouts() => _read(
    _firestore
        .collection(Withdrawal.collection)
        .where(Withdrawal.isMockField, isEqualTo: true),
    Withdrawal.fromDocument,
  );

  Future<Either<Failure, List<T>>> _read<T>(
    Query<Map<String, dynamic>> query,
    T Function(String id, Map<String, dynamic> data) map,
  ) async {
    try {
      final snapshot = await query.get();
      return right([
        for (final document in snapshot.docs) map(document.id, document.data()),
      ]);
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.read(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.mockDataLoadFailed));
    }
  }

  Future<Either<Failure, Map<Object?, Object?>>> _call(String function) async {
    try {
      final response = await _functions
          .httpsCallable(function)
          .call<Map<Object?, Object?>>();
      return right(response.data);
    } on FirebaseFunctionsException catch (error) {
      final message = error.message;
      return left(
        DataFailure(
          message == null || error.code == _internalErrorCode
              ? AppStrings.mockDataFailed
              : message,
        ),
      );
    } catch (_) {
      return left(const DataFailure(AppStrings.mockDataFailed));
    }
  }
}
