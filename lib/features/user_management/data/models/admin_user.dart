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
      userId: record.id,
      phone: record.phoneLabel,
      recharges: null,
      walletBalance: NumberFormatter.grouped(record.walletBalance.truncate()),
      status: _statusOf(record),
      avatarIndex: record.avatarIndex,
    );
  }

  const AdminUser({
    required this.createdDate,
    required this.name,
    required this.initials,
    required this.userId,
    required this.phone,
    required this.recharges,
    required this.walletBalance,
    required this.status,
    required this.avatarIndex,
  });

  final String createdDate;
  final String name;
  final String initials;
  final String userId;
  final String phone;
  final int? recharges;
  final String walletBalance;
  final UserStatus status;
  final int avatarIndex;

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
  }) {
    return AdminUser(
      createdDate: createdDate,
      name: name ?? this.name,
      initials: initials ?? this.initials,
      userId: userId,
      phone: phone ?? this.phone,
      recharges: recharges,
      walletBalance: walletBalance,
      status: status ?? this.status,
      avatarIndex: avatarIndex,
    );
  }
}
