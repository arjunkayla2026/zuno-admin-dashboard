import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._auth);

  static const String _adminClaim = 'admin';

  final FirebaseAuth _auth;

  static AuthFailure failureForCode(String code) => AuthFailure(switch (code) {
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' ||
    'INVALID_LOGIN_CREDENTIALS' => AppStrings.loginFailed,
    'invalid-email' => AppStrings.enterValidEmail,
    'user-disabled' => AppStrings.loginAccountDisabled,
    'too-many-requests' => AppStrings.loginTooManyAttempts,
    'network-request-failed' => AppStrings.loginNetworkError,
    'second-factor-required' ||
    'multi-factor-auth-required' => AppStrings.loginSecondFactorRequired,
    _ => AppStrings.loginUnavailable,
  });

  Future<Either<Failure, Unit>> signIn({
    required String email,
    required String password,
  }) => _guard(() async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    return unit;
  });

  Future<Either<Failure, bool>> isCurrentUserAdmin() => _guard(() async {
    final token = await _auth.currentUser?.getIdTokenResult();
    return token?.claims?[_adminClaim] == true;
  });

  Future<Either<Failure, Unit>> signOut() => _guard(() async {
    await _auth.signOut();
    return unit;
  });

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return right(await action());
    } on FirebaseAuthException catch (error) {
      return left(failureForCode(error.code));
    } catch (_) {
      return left(const AuthFailure(AppStrings.loginUnavailable));
    }
  }
}
