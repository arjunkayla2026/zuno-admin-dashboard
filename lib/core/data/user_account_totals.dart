class UserAccountTotals {
  const UserAccountTotals({
    required this.activeUsers,
    required this.activeHosts,
    required this.deletedUsers,
    required this.deletedHosts,
    required this.deletedWalletBalance,
    required this.bonusUsers,
    required this.bonusAmount,
  });

  final int activeUsers;
  final int activeHosts;
  final int deletedUsers;
  final int deletedHosts;
  final double deletedWalletBalance;
  final int bonusUsers;
  final double bonusAmount;

  UserAccountTotals withBonus({required int users, required double amount}) =>
      UserAccountTotals(
        activeUsers: activeUsers,
        activeHosts: activeHosts,
        deletedUsers: deletedUsers,
        deletedHosts: deletedHosts,
        deletedWalletBalance: deletedWalletBalance,
        bonusUsers: users,
        bonusAmount: amount,
      );
}
