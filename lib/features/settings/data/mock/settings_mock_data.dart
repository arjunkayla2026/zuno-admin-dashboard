import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_nav_item.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/host_profile_options.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/admin_account.dart';

abstract final class SettingsMockData {
  static const int activeUsers = 8240;

  static const Map<HostLanguage, int> activeHostsByLanguage = {
    HostLanguage.english: 142,
    HostLanguage.malayalam: 412,
    HostLanguage.tamil: 236,
    HostLanguage.hindi: 128,
    HostLanguage.kannada: 96,
    HostLanguage.telugu: 112,
  };

  static const List<AdminAccount> admins = [
    AdminAccount(
      name: 'Rakesh Menon',
      email: 'rakesh@yellowcalling.app',
      role: AdminRole.superAdmin,
      phone: '+91 98470 11234',
    ),
    AdminAccount(
      name: 'Divya Suresh',
      email: 'divya@yellowcalling.app',
      role: AdminRole.financeAdmin,
      phone: '+91 94461 55320',
      modules: [
        AdminNavItem.dashboard,
        AdminNavItem.recharge,
        AdminNavItem.payment,
        AdminNavItem.packages,
      ],
    ),
    AdminAccount(
      name: 'Joel Mathew',
      email: 'joel@yellowcalling.app',
      role: AdminRole.supportAdmin,
      phone: '+91 90372 88101',
      modules: [
        AdminNavItem.userManagement,
        AdminNavItem.hostManagement,
        AdminNavItem.calls,
        AdminNavItem.reports,
      ],
    ),
    AdminAccount(
      name: 'Nisha Ramesh',
      email: 'nisha@yellowcalling.app',
      role: AdminRole.moderator,
      phone: '+91 97782 40917',
      modules: [AdminNavItem.approval, AdminNavItem.reports],
    ),
  ];
}
