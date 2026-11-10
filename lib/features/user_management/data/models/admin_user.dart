import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/name_formatter.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';

enum UserStatus { active, newUser, blocked, deletedByAdmin, deletedByUser }

class AdminUser {
  factory AdminUser.fromRecord(UserRecord record) {
    final name = record.name ?? record.userName ?? AppStrings.emptyValue;

    return AdminUser(
      createdDate: record.createdDateLabel,
      name: name,
      initials: NameFormatter.initials(name),
      id: record.id,
      phone: record.phoneLabel,
      recharges: null,
      walletBalance: NumberFormatter.grouped(record.walletBalance.truncate()),
      adminCredit: record.adminCredit.truncate(),
      adminDebit: record.adminDebit.truncate(),
      status: _statusOf(record),
      avatarIndex: record.avatarIndex,
      userID: '',
    );
  }

  const AdminUser({
    required this.createdDate,
    required this.name,
    required this.initials,
    required this.id,
    required this.phone,
    required this.recharges,
    required this.walletBalance,
    required this.status,
    required this.avatarIndex,
    required this.userID,
    this.adminCredit = 0,
    this.adminDebit = 0,
  });

  final String createdDate;
  final String name;
  final String initials;
  final String id;
  final String phone;
  final int? recharges;
  final String walletBalance;
  final UserStatus status;
  final int avatarIndex;
  final String userID;
  final int adminCredit;
  final int adminDebit;

  static UserStatus _statusOf(UserRecord record) {
    if (record.isDeleted) {
      return record.isDeletedByAdmin
          ? UserStatus.deletedByAdmin
          : UserStatus.deletedByUser;
    }
    if (record.isBlocked) return UserStatus.blocked;
    if (record.isNewAccount) return UserStatus.newUser;
    return UserStatus.active;
  }

  bool get hasActions =>
      status != UserStatus.deletedByAdmin && status != UserStatus.deletedByUser;

  AdminUser withEditedDetails({required String name, required String phone}) =>
      copyWith(
        name: name,
        initials: NameFormatter.initials(name),
        phone: phone,
      );

  AdminUser copyWith({
    String? name,
    String? initials,
    String? phone,
    UserStatus? status,
    String? walletBalance,
    int? adminCredit,
    int? adminDebit,
  }) {
    return AdminUser(
      createdDate: createdDate,
      name: name ?? this.name,
      initials: initials ?? this.initials,
      id: id,
      userID: userID,
      phone: phone ?? this.phone,
      recharges: recharges,
      walletBalance: walletBalance ?? this.walletBalance,
      adminCredit: adminCredit ?? this.adminCredit,
      adminDebit: adminDebit ?? this.adminDebit,
      status: status ?? this.status,
      avatarIndex: avatarIndex,
    );
  }
}
