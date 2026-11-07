import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';

enum AdminSubNavItem {
  hostList(AppStrings.hostList, route: AppRoutes.hostManagement),
  surgeChargeSessions(
    AppStrings.surgeChargeSessions,
    route: AppRoutes.surgeChargeSessions,
  ),
  hostRequests(AppStrings.hostRequests, route: AppRoutes.approval),
  payoutReview(AppStrings.payoutReview),
  profilePhotoReview(AppStrings.profilePhotoReview),
  packageList(AppStrings.packageList, route: AppRoutes.packages),
  couponList(AppStrings.couponList);

  const AdminSubNavItem(this.label, {this.route});

  final String label;
  final String? route;
}

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
  hostManagement(
    AppStrings.hostManagement,
    AppImages.hostManagementIcon,
    route: AppRoutes.hostManagement,
    subItems: [AdminSubNavItem.hostList, AdminSubNavItem.surgeChargeSessions],
  ),
  calls(AppStrings.calls, AppImages.callIcon, route: AppRoutes.calls),
  approval(
    AppStrings.approval,
    AppImages.approvalIcon,
    route: AppRoutes.approval,
    subItems: [
      AdminSubNavItem.hostRequests,
      AdminSubNavItem.payoutReview,
      AdminSubNavItem.profilePhotoReview,
    ],
  ),
  reports(AppStrings.reports, AppImages.flagIcon, route: AppRoutes.reports),
  packages(
    AppStrings.packages,
    AppImages.packagesIcon,
    route: AppRoutes.packages,
    subItems: [AdminSubNavItem.packageList, AdminSubNavItem.couponList],
  ),
  recharge(
    AppStrings.recharge,
    AppImages.rechargeIcon,
    route: AppRoutes.recharge,
  ),
  payment(AppStrings.payment, AppImages.paymentIcon),
  settings(AppStrings.settings, AppImages.settingsIcon);

  const AdminNavItem(
    this.label,
    this.svgAsset, {
    this.route,
    this.subItems = const [],
  });

  final String label;
  final String svgAsset;
  final String? route;
  final List<AdminSubNavItem> subItems;
}
