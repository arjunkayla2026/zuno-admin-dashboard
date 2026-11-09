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

  DocumentReference<Map<String, dynamic>> _document(String email) =>
      _admins.doc(AdminAccount.normalizeEmail(email));

  Future<Either<Failure, List<AdminAccount>>> fetchAdmins() => _read(() async {
    final snapshot = await _admins.get();
    return [
      for (final document in snapshot.docs)
        AdminAccount.fromDocument(document.data(), document.id),
    ];
  });

  Future<Either<Failure, AdminAccount?>> findByEmail(String email) => _read(
    () async {
      final snapshot = await _document(email).get();
      final data = snapshot.data();
      return data == null ? null : AdminAccount.fromDocument(data, snapshot.id);
    },
  );

  Future<Either<Failure, bool>> hasAnyAdmin() => _read(() async {
    final snapshot = await _admins.limit(1).get();
    return snapshot.docs.isNotEmpty;
  });

  Future<Either<Failure, Unit>> createAdmin(AdminAccount admin) async {
    final reference = _document(admin.email);
    var exists = false;
    final result = await _write(
      () => _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(reference);
        if (snapshot.exists) {
          exists = true;
          return;
        }
        transaction.set(reference, {
          ...admin.toFields(),
          AdminAccount.createdAtField: FieldValue.serverTimestamp(),
          AdminAccount.updatedAtField: FieldValue.serverTimestamp(),
        });
      }),
    );
    if (exists) return left(const DataFailure(AppStrings.adminEmailExists));
    return result;
  }

  Future<Either<Failure, Unit>> updateAdmin(AdminAccount admin) {
    final fields = admin.toFields()..remove(AdminAccount.emailField);
    return _write(
      () => _document(admin.email).update({
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
