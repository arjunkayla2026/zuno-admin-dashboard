import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/name_formatter.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';

enum UserStatus { active, newUser, blocked, deletedByAdmin, deletedByUser }

class AdminUser {
  factory AdminUser.fromRecord(UserRecord record) {
    final name = record.userName ?? record.name ?? AppStrings.emptyValue;

    return AdminUser(
      createdDate: record.createdDateLabel,
      name: name,
      initials: NameFormatter.initials(name),
      id: record.id,
      phone: record.phoneLabel,
      recharges: null,
      walletBalance: NumberFormatter.grouped(record.walletBalance.truncate()),
      walletAmount: record.walletBalance.toDouble(),
      adminCredit: record.adminCredit.truncate(),
      adminDebit: record.adminDebit.truncate(),
      status: _statusOf(record),
      avatarIndex: record.avatarIndex,
      userID: record.userIDLabel,
      updatedAt: record.updatedAt,
      imageUrl: record.profileImageUrl,
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
    this.walletAmount,
    this.updatedAt,
    this.imageUrl,
  });

  final String createdDate;
  final String name;
  final String initials;
  final String id;
  final String phone;

  /// The user's completed recharges (gateway and admin), counted from
  /// `transactions`. Null until counted, or when counting failed.
  final int? recharges;

  /// `walletBalance` rounded down and grouped, for the user list.
  final String walletBalance;

  /// The exact `walletBalance` in rupees (billing leaves up to six
  /// decimals). Null only for users built without a Firestore record.
  final double? walletAmount;
  final UserStatus status;
  final int avatarIndex;
  final String userID;
  final int adminCredit;
  final int adminDebit;

  /// The user document's `updatedAt`, shown as Last Online.
  final DateTime? updatedAt;

  /// The profile picture (`avatharImage`) the user picked in the app.
  final String? imageUrl;

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

  /// Exact wallet balance in rupees; coins are worked out from this.
  double get walletRupees =>
      walletAmount ?? NumberFormatter.parse(walletBalance).toDouble();

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
    double? walletAmount,
    int? adminCredit,
    int? adminDebit,
    int? recharges,
  }) {
    return AdminUser(
      createdDate: createdDate,
      name: name ?? this.name,
      initials: initials ?? this.initials,
      id: id,
      userID: userID,
      phone: phone ?? this.phone,
      recharges: recharges ?? this.recharges,
      walletBalance: walletAmount == null
          ? walletBalance
          : NumberFormatter.grouped(walletAmount.truncate()),
      walletAmount: walletAmount ?? this.walletAmount,
      adminCredit: adminCredit ?? this.adminCredit,
      adminDebit: adminDebit ?? this.adminDebit,
      status: status ?? this.status,
      avatarIndex: avatarIndex,
      updatedAt: updatedAt,
      imageUrl: imageUrl,
    );
  }
}
