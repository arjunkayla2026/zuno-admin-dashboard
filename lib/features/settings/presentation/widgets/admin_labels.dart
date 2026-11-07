import 'package:zuno_admin_dashboard/core/enums/app_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/admin_account.dart';

abstract final class AdminLabels {
  static (String, AppStatus) role(AdminRole role) => switch (role) {
    AdminRole.superAdmin => (AppStrings.superAdmin, AppStatus.pending),
    AdminRole.financeAdmin => (AppStrings.financeAdmin, AppStatus.isNew),
    AdminRole.supportAdmin => (AppStrings.supportAdmin, AppStatus.isNew),
    AdminRole.moderator => (AppStrings.moderator, AppStatus.isNew),
  };
}
