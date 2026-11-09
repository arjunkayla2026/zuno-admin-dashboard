import 'package:zuno_admin_dashboard/core/data/admin_account.dart';

enum AuthStatus { initial, loading, success, signedOut, failure }

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.account,
  });

  final AuthStatus status;
  final String? errorMessage;
  final AdminAccount? account;

  bool get isLoading => status == AuthStatus.loading;
}
