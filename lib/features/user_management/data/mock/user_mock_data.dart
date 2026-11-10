import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';

abstract final class UserMockData {
  static const String adminName = 'Rakesh Menon';
  static const String adminRole = 'Super Admin';
  static const String adminInitials = 'RM';

  static const int _totalUsers = 44;

  static const List<AdminUser> _screenshotUsers = [
    AdminUser(
      createdDate: '01 Nov 2026',
      name: 'Arjun Nair',
      initials: 'AN',
      id: 'ZU10231',
      phone: '+91 78613 87558',
      recharges: 7,
      walletBalance: '2,098',
      status: UserStatus.newUser,
      avatarIndex: 0,
      userID: 'ZUIH565',
    ),
    AdminUser(
      createdDate: '02 Nov 2026',
      name: 'Rahul Menon',
      initials: 'RM',
      userID: 'ZU10232',
      phone: '+91 77762 43765',
      recharges: 2,
      walletBalance: '347',
      status: UserStatus.newUser,
      avatarIndex: 1,
      id: '67786CDTS7DSAD',
    ),
    AdminUser(
      createdDate: '02 Nov 2026',
      name: 'Vishnu Das',
      initials: 'VD',
      userID: '10233',
      phone: '+91 66020 11792',
      recharges: 2,
      walletBalance: '1,989',
      status: UserStatus.newUser,
      avatarIndex: 2,
      id: 'DADASD',
    ),
    AdminUser(
      createdDate: '30 Oct 2026',
      name: 'Akhil Kumar',
      initials: 'AK',
      userID: 'ZU10234',
      phone: '+91 85807 58311',
      recharges: 1,
      walletBalance: '1,368',
      status: UserStatus.blocked,
      avatarIndex: 3,
      id: 'ASDASDSA',
    ),
    AdminUser(
      createdDate: '29 Oct 2026',
      name: 'Sanjay Rao',
      initials: 'SR',
      userID: 'ZU10235',
      phone: '+91 81735 19835',
      recharges: 1,
      walletBalance: '2,282',
      status: UserStatus.newUser,
      avatarIndex: 4,
      id: 'ASDASD332E',
    ),
    AdminUser(
      createdDate: '06 Sep 2026',
      name: 'Faisal Muhammed',
      initials: 'FM',
      userID: 'ZU10236',
      phone: '+91 79892 58588',
      recharges: 0,
      walletBalance: '2,190',
      status: UserStatus.deletedByAdmin,
      avatarIndex: 5,
      id: 'ASDASD332E',
    ),
  ];

  static final List<AdminUser> users = [
    ..._screenshotUsers,
    for (var i = _screenshotUsers.length; i < _totalUsers; i++)
      AdminUser(
        createdDate: '01 Jun 2026',
        name: 'Test User ${i + 1}',
        initials: 'TU',
        id: ' ZU${10231 + i}',
        phone: '+91 90000 ${(10000 + i)}',
        recharges: 0,
        walletBalance: '0',
        status: UserStatus.active,
        avatarIndex: i,
        userID: 'ASDASD332E',
      ),
  ];
}
