enum UserStatus { active, newUser, blocked, deletedByAdmin, deletedByUser }

class AdminUser {
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
  final int recharges;
  final String walletBalance;
  final UserStatus status;
  final int avatarIndex;

  bool get hasActions =>
      status != UserStatus.deletedByAdmin && status != UserStatus.deletedByUser;

  AdminUser copyWith({UserStatus? status}) {
    return AdminUser(
      createdDate: createdDate,
      name: name,
      initials: initials,
      userId: userId,
      phone: phone,
      recharges: recharges,
      walletBalance: walletBalance,
      status: status ?? this.status,
      avatarIndex: avatarIndex,
    );
  }
}
