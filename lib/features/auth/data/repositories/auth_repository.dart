import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/auth/data/datasources/auth_remote_data_source.dart';

class AuthRepository {
  const AuthRepository(this._dataSource);

  final AuthRemoteDataSource _dataSource;

  Future<Either<Failure, Unit>> signOut() async {
    final result = await _dataSource.signOut();
    return result.mapLeft((_) => const AuthFailure(AppStrings.logoutFailed));
  }

  Future<Either<Failure, Unit>> signIn({
    required String email,
    required String password,
  }) async {
    final signedIn = await _dataSource.signIn(email: email, password: password);
    if (signedIn.isLeft()) return signedIn;

    final isAdmin = await _dataSource.isCurrentUserAdmin();
    if (isAdmin.getOrElse((_) => false)) return right(unit);

    await _dataSource.signOut();
    return isAdmin.flatMap(
      (_) => left(const AuthFailure(AppStrings.loginFailed)),
    );
  }
}
