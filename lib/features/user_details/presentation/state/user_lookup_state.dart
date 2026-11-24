import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';

class UserLookupState {
  const UserLookupState({
    this.status = LoadStatus.loading,
    this.user,
    this.errorMessage,
  });

  final LoadStatus status;
  final AdminUser? user;
  final String? errorMessage;
}
