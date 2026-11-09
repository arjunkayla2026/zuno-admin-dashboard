import 'package:zuno_admin_dashboard/core/data/admin_account.dart';
import 'package:zuno_admin_dashboard/core/enums/app_status.dart';

abstract final class AdminLabels {
  static (String, AppStatus) role(AdminRole role) => (
    role.label,
    role == AdminRole.superAdmin ? AppStatus.pending : AppStatus.isNew,
  );
}
