import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/admin_account.dart';
import 'package:zuno_admin_dashboard/core/data/admins_remote_data_source.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/auth/data/datasources/auth_remote_data_source.dart';

class AuthRepository {
  const AuthRepository(this._dataSource, this._adminsDataSource);

  final AuthRemoteDataSource _dataSource;
  final AdminsRemoteDataSource _adminsDataSource;

  Future<Either<Failure, Unit>> signOut() async {
    final result = await _dataSource.signOut();
    return result.mapLeft((_) => const AuthFailure(AppStrings.logoutFailed));
  }

  Future<Either<Failure, AdminAccount>> signIn({
    required String email,
    required String password,
  }) async {
    final signedIn = await _dataSource.signIn(email: email, password: password);
    if (signedIn case Left(:final value)) return left(value);

    final account = await _currentAccount();
    final resolved = switch (account) {
      Right(value: final admin?) => right<Failure, AdminAccount>(admin),
      Right() => left<Failure, AdminAccount>(
        const AuthFailure(AppStrings.loginFailed),
      ),
      Left(:final value) => left<Failure, AdminAccount>(value),
    };
    if (resolved.isLeft()) await _dataSource.signOut();
    return resolved;
  }

  Future<Either<Failure, AdminAccount?>> restoreSession() async {
    final account = await _currentAccount();
    if (account case Left(value: AuthFailure())) {
      await _dataSource.signOut();
      return right(null);
    }
    return account;
  }

  Future<Either<Failure, AdminAccount?>> _currentAccount() async {
    final session = await _dataSource.restoreSession();
    if (session case Left(:final value)) return left(value);
    final user = session.getOrElse((_) => null);
    if (user == null) return right(null);

    final existing = await _adminsDataSource.findByEmail(user.email);
    if (existing case Left(:final value)) {
      return value is DataFailure &&
              value.message == AppStrings.recordsAccessDenied
          ? left(const AuthFailure(AppStrings.loginFailed))
          : left(value);
    }
    if (existing.getOrElse((_) => null) case final admin?) {
      return admin.homeRoute == null
          ? left(const AuthFailure(AppStrings.loginNoAccess))
          : right(admin);
    }

    final isAdmin = await _dataSource.isCurrentUserAdmin();
    if (isAdmin case Left(:final value)) return left(value);
    if (!isAdmin.getOrElse((_) => false)) {
      return left(const AuthFailure(AppStrings.loginFailed));
    }
    return _claimFirstAdmin(user.email, user.displayName);
  }

  Future<Either<Failure, AdminAccount?>> _claimFirstAdmin(
    String email,
    String? displayName,
  ) async {
    final hasAdmins = await _adminsDataSource.hasAnyAdmin();
    if (hasAdmins case Left(:final value)) return left(value);
    if (hasAdmins.getOrElse((_) => true)) {
      return left(const AuthFailure(AppStrings.loginNoAccess));
    }

    final owner = AdminAccount(
      name: displayName ?? email.split('@').first,
      email: AdminAccount.normalizeEmail(email),
      role: AdminRole.superAdmin,
      phone: '',
      createdAt: DateTime.now(),
    );
    final created = await _adminsDataSource.createAdmin(owner);
    return created.map((_) => owner);
  }
}
