import 'package:zuno_admin_dashboard/core/data/admin_account.dart';

enum AdminSessionStatus { loading, signedIn, signedOut, failure }

class AdminSessionState {
  const AdminSessionState({
    this.status = AdminSessionStatus.loading,
    this.account,
    this.errorMessage,
  });

  final AdminSessionStatus status;
  final AdminAccount? account;
  final String? errorMessage;
}
