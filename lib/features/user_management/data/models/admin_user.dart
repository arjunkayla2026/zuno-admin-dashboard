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

  static String initialsFor(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    final first = words.first;
    if (first.isEmpty) return '';
    final last = words.length > 1 ? words.last : '';
    return (first[0] + (last.isEmpty ? '' : last[0])).toUpperCase();
  }

  AdminUser withEditedDetails({required String name, required String phone}) =>
      copyWith(name: name, initials: initialsFor(name), phone: phone);

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
