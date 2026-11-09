import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/features/auth/data/repositories/auth_repository.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/state/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  Future<void> signIn({required String email, required String password}) async {
    if (state.isLoading) return;

    final trimmedEmail = email.trim();
    if (!AppUtils.isValidEmail(trimmedEmail)) {
      return _fail(AppStrings.enterValidEmail);
    }
    if (password.isEmpty) return _fail(AppStrings.enterPassword);

    emit(const AuthState(status: AuthStatus.loading));
    final result = await _repository.signIn(
      email: trimmedEmail,
      password: password,
    );
    if (isClosed) return;

    result.match(
      (failure) => _fail(failure.message),
      (_) => emit(const AuthState(status: AuthStatus.success)),
    );
  }

  Future<void> signOut() async {
    if (state.isLoading) return;

    emit(const AuthState(status: AuthStatus.loading));
    final result = await _repository.signOut();
    if (isClosed) return;

    result.match(
      (failure) => _fail(failure.message),
      (_) => emit(const AuthState(status: AuthStatus.signedOut)),
    );
  }

  void _fail(String message) =>
      emit(AuthState(status: AuthStatus.failure, errorMessage: message));
}
