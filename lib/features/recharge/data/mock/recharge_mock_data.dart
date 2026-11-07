import 'package:zuno_admin_dashboard/features/recharge/data/models/recharge_transaction.dart';

typedef _Customer = ({String name, String id, String phone, int avatarIndex});

abstract final class RechargeMockData {
  static final DateTime today = DateTime(2026, 11, 4);

  static const Map<int, int> _coinsForPrice = {
    49: 100,
    99: 250,
    199: 550,
    449: 1400,
    999: 2900,
  };
  static const int _coinsPerRupee = 2;
  static const String _alphabet =
      'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789';

  static const _Customer _arjun = (
    name: 'Arjun Nair',
    id: 'ZU10231',
    phone: '+91 78613 87558',
    avatarIndex: 0,
  );
  static const _Customer _deepak = (
    name: 'Deepak Shetty',
    id: 'ZU10301',
    phone: '+91 96443 38340',
    avatarIndex: 0,
  );
  static const _Customer _ajay = (
    name: 'Ajay Prakash',
    id: 'ZU10302',
    phone: '+91 82191 37107',
    avatarIndex: 5,
  );
  static const _Customer _salman = (
    name: 'Salman Faris',
    id: 'ZU10303',
    phone: '+91 79325 12747',
    avatarIndex: 3,
  );
  static const _Customer _vishnu = (
    name: 'Vishnu Das',
    id: 'ZU10233',
    phone: '+91 66020 11792',
    avatarIndex: 2,
  );
  static const _Customer _harish = (
    name: 'Harish V',
    id: 'ZU10304',
    phone: '+91 79073 67339',
    avatarIndex: 7,
  );
  static const _Customer _rahul = (
    name: 'Rahul Menon',
    id: 'ZU10232',
    phone: '+91 77762 43765',
    avatarIndex: 1,
  );
  static const _Customer _anand = (
    name: 'Anand Krishnan',
    id: 'ZU10240',
    phone: '+91 67719 52861',
    avatarIndex: 1,
  );
  static const _Customer _naveen = (
    name: 'Naveen Reddy',
    id: 'ZU10305',
    phone: '+91 61549 15756',
    avatarIndex: 6,
  );

  static const List<_Customer> _customers = [
    _arjun,
    _deepak,
    _ajay,
    _salman,
    _vishnu,
    _harish,
    _rahul,
    _anand,
    _naveen,
  ];

  static RechargeTransaction _recharge(
    DateTime dateTime,
    _Customer customer,
    int price, {
    required String orderId,
    String? paymentId,
    RechargeStatus status = RechargeStatus.completed,
  }) => RechargeTransaction(
    status: status,
    dateTime: dateTime,
    userName: customer.name,
    userId: customer.id,
    phone: customer.phone,
    kind: RechargeKind.recharge,
    amount: price,
    coins: _coinsForPrice[price]!,
    paymentId: paymentId,
    orderId: orderId,
    gateway: paymentId == null
        ? RechargeGateway.admin
        : RechargeGateway.razorpay,
    avatarIndex: customer.avatarIndex,
  );

  static String _code(int seed, int length) {
    var value = seed * 7919 + 104729;
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      value = (value * 48271 + 11) % 2147483647;
      buffer.write(_alphabet[value % _alphabet.length]);
    }
    return buffer.toString();
  }

  static DateTime _at(int hour, int minute) =>
      DateTime(today.year, today.month, today.day, hour, minute);

  static List<RechargeTransaction> get _screenshotTransactions => [
    _recharge(_at(10, 8), _arjun, 199, orderId: 'ADM-WWQDENH7'),
    _recharge(
      _at(18, 33),
      _deepak,
      449,
      paymentId: 'pay_xUFwtVn4e8',
      orderId: 'order_zkdeX29XqY',
    ),
    _recharge(
      _at(16, 33),
      _ajay,
      999,
      paymentId: 'pay_AoLFzPHbHo',
      orderId: 'order_8FjUGtD29c',
    ),
    _recharge(
      _at(15, 29),
      _salman,
      199,
      paymentId: 'pay_zqyjGCrQH7',
      orderId: 'order_ELdvokxht7',
    ),
    _recharge(
      _at(15, 19),
      _vishnu,
      99,
      paymentId: 'pay_QtpKuj1Zgq',
      orderId: 'order_nYRz16KWUG',
    ),
    _recharge(
      _at(15, 19),
      _harish,
      99,
      paymentId: 'pay_Q8zJXsuBAQ',
      orderId: 'order_fhR8by3n3t',
    ),
    _recharge(
      _at(13, 59),
      _deepak,
      199,
      paymentId: 'pay_Zz24HS40Aq',
      orderId: 'order_P2gFA0nCnF',
    ),
    _recharge(
      _at(12, 48),
      _arjun,
      449,
      paymentId: 'pay_0DbdhzBz43',
      orderId: 'order_xjFLPtmZYZ',
    ),
    _recharge(_at(9, 41), _rahul, 49, orderId: 'ADM-A413F7EK'),
    _recharge(_at(8, 19), _anand, 199, orderId: 'ADM-TH9FABZU'),
    _recharge(
      _at(8, 2),
      _naveen,
      449,
      paymentId: 'pay_8bAFv1Syff',
      orderId: 'order_6z7vdtn5AB',
    ),
  ];

  static const List<int> _creditAmounts = [
    100,
    50,
    100,
    50,
    100,
    100,
    50,
    100,
    100,
    100,
  ];
  static const List<int> _debitAmounts = [20, 20, 30, 20, 20, 20, 20, 20];

  static List<int> get _rechargePrices {
    final prices = [
      for (var i = 0; i < 6; i++) 49,
      for (var i = 0; i < 4; i++) 99,
      for (var i = 0; i < 12; i++) 199,
      for (var i = 0; i < 12; i++) 449,
      for (var i = 0; i < 8; i++) 999,
    ];
    return [
      for (var i = 0; i < prices.length; i++) prices[i * 5 % prices.length],
    ];
  }

  static List<RechargeTransaction> _buildGenerated() {
    const total = 60;
    const slotsPerDay = 6;
    final prices = _rechargePrices;
    var priceIndex = 0;
    var creditIndex = 0;
    var debitIndex = 0;

    return [
      for (var i = 0; i < total; i++)
        () {
          final customer = _customers[(i * 4) % _customers.length];
          final dateTime = DateTime(
            today.year,
            today.month,
            today.day - 1 - i ~/ slotsPerDay,
            21 - (i % slotsPerDay) * 2,
            (i * 13) % 60,
          );
          final seed = i + 100;
          final adminOrder = 'ADM-${_code(seed, 8).toUpperCase()}';

          if (i % slotsPerDay == 2 && creditIndex < _creditAmounts.length) {
            final amount = _creditAmounts[creditIndex++];
            return RechargeTransaction(
              dateTime: dateTime,
              userName: customer.name,
              userId: customer.id,
              phone: customer.phone,
              kind: RechargeKind.credit,
              amount: amount,
              coins: amount * _coinsPerRupee,
              orderId: adminOrder,
              gateway: RechargeGateway.admin,
              avatarIndex: customer.avatarIndex,
            );
          }
          if (i % slotsPerDay == 5 && debitIndex < _debitAmounts.length) {
            final amount = _debitAmounts[debitIndex++];
            return RechargeTransaction(
              dateTime: dateTime,
              userName: customer.name,
              userId: customer.id,
              phone: customer.phone,
              kind: RechargeKind.debit,
              amount: amount,
              coins: 0,
              orderId: adminOrder,
              gateway: RechargeGateway.admin,
              avatarIndex: customer.avatarIndex,
            );
          }

          final price = prices[priceIndex++];
          final viaAdmin = i % 3 == 0;
          final status = viaAdmin
              ? RechargeStatus.completed
              : switch (i % 10) {
                  1 => RechargeStatus.failed,
                  7 => RechargeStatus.created,
                  _ => RechargeStatus.completed,
                };
          return _recharge(
            dateTime,
            customer,
            price,
            paymentId: viaAdmin ? null : 'pay_${_code(seed, 10)}',
            orderId: viaAdmin ? adminOrder : 'order_${_code(seed + 500, 10)}',
            status: status,
          );
        }(),
    ];
  }

  static final List<RechargeTransaction> transactions = [
    ..._screenshotTransactions,
    ..._buildGenerated(),
  ];
}
