class RechargePackage {
  const RechargePackage({
    required this.price,
    required this.coins,
    this.bonus = 0,
  });

  final int price;
  final int coins;
  final int bonus;

  int get totalCoins => coins + bonus;

  bool get hasBonus => bonus > 0;
}
