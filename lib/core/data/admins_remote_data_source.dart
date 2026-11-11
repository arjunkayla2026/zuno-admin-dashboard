import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/admin_account.dart';
import 'package:zuno_admin_dashboard/core/data/firestore_failures.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';

class AdminsRemoteDataSource {
  const AdminsRemoteDataSource(this._firestore);

  static const String _collection = 'admin';
  static const String _loginAppName = 'admin-logins';
  static const String _emailInUse = 'email-already-in-use';

  final FirebaseFirestore _firestore;

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

  Future<Either<Failure, Unit>> updateAdmin(AdminAccount admin) {
    if (admin.id.isEmpty) {
      return Future.value(
        left(const DataFailure(AppStrings.recordsSaveFailed)),
      );
    }
    final fields = admin.toFields()..remove(AdminAccount.emailField);
    return _write(
      () => _admins.doc(admin.id).update({
        ...fields,
        AdminAccount.updatedAtField: FieldValue.serverTimestamp(),
      }),
    );
  }

  Future<Either<Failure, Unit>> createLogin({
    required String email,
    required String password,
    bool keepExisting = true,
  }) async {
    FirebaseAuth? auth;
    try {
      final app =
          Firebase.apps.where((app) => app.name == _loginAppName).firstOrNull ??
          await Firebase.initializeApp(
            name: _loginAppName,
            options: _firestore.app.options,
          );
      auth = FirebaseAuth.instanceFor(app: app);
      await auth.setPersistence(Persistence.NONE);
      await auth.createUserWithEmailAndPassword(
        email: AdminAccount.normalizeEmail(email),
        password: password,
      );
      return right(unit);
    } on FirebaseAuthException catch (error) {
      if (error.code == _emailInUse) {
        return keepExisting
            ? right(unit)
            : left(const DataFailure(AppStrings.adminLoginExists));
      }
      return left(_loginFailure(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.adminLoginCreateFailed));
    } finally {
      await auth?.signOut().onError((_, _) {});
    }
  }

  static DataFailure _loginFailure(String code) => DataFailure(switch (code) {
    'weak-password' ||
    'password-does-not-meet-requirements' => AppStrings.adminLoginWeakPassword,
    'invalid-email' => AppStrings.enterValidEmail,
    'operation-not-allowed' => AppStrings.adminLoginsDisabled,
    'network-request-failed' => AppStrings.recordsNetworkError,
    _ => AppStrings.adminLoginCreateFailed,
  });

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
