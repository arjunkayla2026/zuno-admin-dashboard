enum AuthStatus { initial, loading, success, signedOut, failure }

class AuthState {
  const AuthState({this.status = AuthStatus.initial, this.errorMessage});

  final AuthStatus status;
  final String? errorMessage;

  bool get isLoading => status == AuthStatus.loading;
}
