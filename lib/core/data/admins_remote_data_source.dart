import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/admin_account.dart';
import 'package:zuno_admin_dashboard/core/data/firestore_failures.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';

class AdminsRemoteDataSource {
  const AdminsRemoteDataSource(this._firestore, this._functions);

  static const String _collection = 'admin';
  static const String _saveFunction = 'saveAdminAccount';
  static const String _idKey = 'id';
  static const String _passwordKey = 'password';
  static const Duration _timeout = Duration(minutes: 1);

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>> get _admins =>
      _firestore.collection(_collection);

  Query<Map<String, dynamic>> _byEmail(String email) => _admins
      .where(
        AdminAccount.emailField,
        isEqualTo: AdminAccount.normalizeEmail(email),
      )
      .limit(1);

  Future<Either<Failure, List<AdminAccount>>> fetchAdmins() => _read(() async {
    final snapshot = await _admins.get();
    return [
      for (final document in snapshot.docs)
        AdminAccount.fromDocument(document.data(), document.id),
    ];
  });

  Future<Either<Failure, AdminAccount?>> findByEmail(String email) =>
      _read(() async {
        final snapshot = await _byEmail(email).get();
        final document = snapshot.docs.firstOrNull;
        return document == null
            ? null
            : AdminAccount.fromDocument(document.data(), document.id);
      });

  Future<Either<Failure, bool>> hasAnyAdmin() => _read(() async {
    final snapshot = await _admins.limit(1).get();
    return snapshot.docs.isNotEmpty;
  });

  Future<Either<Failure, String>> createAdmin(AdminAccount admin) async {
    final existing = await findByEmail(admin.email);
    if (existing case Left(:final value)) return left(value);
    if (existing.getOrElse((_) => null) != null) {
      return left(const DataFailure(AppStrings.adminEmailExists));
    }

    final reference = _admins.doc();
    final result = await _write(
      () => reference.set({
        ...admin.toFields(),
        AdminAccount.createdAtField: FieldValue.serverTimestamp(),
        AdminAccount.updatedAtField: FieldValue.serverTimestamp(),
      }),
    );
    return result.map((_) => reference.id);
  }

  Future<Either<Failure, String>> saveAdmin(
    AdminAccount admin, {
    String? password,
  }) async {
    try {
      final result = await _functions
          .httpsCallable(
            _saveFunction,
            options: HttpsCallableOptions(timeout: _timeout),
          )
          .call<Map<Object?, Object?>>({
            ...admin.toFields(),
            if (admin.id.isNotEmpty) _idKey: admin.id,
            _passwordKey: ?password,
          });
      final id = result.data[_idKey];
      return id is String && id.isNotEmpty
          ? right(id)
          : left(const DataFailure(AppStrings.recordsSaveFailed));
    } on FirebaseFunctionsException catch (error) {
      return left(DataFailure(_saveFailure(error)));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsSaveFailed));
    }
  }

  static String _saveFailure(FirebaseFunctionsException error) =>
      switch (error.code) {
        'unavailable' || 'deadline-exceeded' => AppStrings.recordsNetworkError,
        'unauthenticated' => AppStrings.adminSaveDenied,
        'already-exists' => AppStrings.adminEmailExists,
        _ => error.message ?? AppStrings.recordsSaveFailed,
      };

  Future<Either<Failure, T>> _read<T>(Future<T> Function() action) async {
    try {
      return right(await action());
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.read(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }

  Future<Either<Failure, Unit>> _write(Future<void> Function() action) async {
    try {
      await action();
      return right(unit);
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.write(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsSaveFailed));
    }
  }
}
