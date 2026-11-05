import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';

enum AdminNavItem {
  dashboard(
    AppStrings.dashboard,
    AppImages.dashboardIcon,
    route: AppRoutes.dashboard,
  ),
  userManagement(
    AppStrings.userManagement,
    AppImages.userManagementIcon,
    route: AppRoutes.userManagement,
  ),
  hostManagement(AppStrings.hostManagement, AppImages.hostManagementIcon),
  calls(AppStrings.calls, AppImages.callIcon),
  approval(AppStrings.approval, AppImages.approvalIcon),
  reports(AppStrings.reports, AppImages.flagIcon),
  packages(AppStrings.packages, AppImages.packagesIcon),
  recharge(AppStrings.recharge, AppImages.rechargeIcon),
  payment(AppStrings.payment, AppImages.paymentIcon),
  settings(AppStrings.settings, AppImages.settingsIcon);

  const AdminNavItem(this.label, this.svgAsset, {this.route});

  final String label;
  final String svgAsset;
  final String? route;
}
