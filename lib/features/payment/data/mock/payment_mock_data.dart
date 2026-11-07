import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/mock/host_mock_data.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';

typedef _PaymentHost = ({
  String name,
  String hostId,
  int avatarIndex,
  String branchName,
  String accountHolderName,
  String accountNumber,
  String ifscCode,
});

typedef _WithdrawalFigures = ({
  int callCount,
  int callMinutes,
  int amountEarned,
  int totalAmount,
});

abstract final class PaymentMockData {
  static const int minimumWithdrawal = 300;
  static const int tdsPercent = 2;
  static final DateTime today = DateTime(2026, 11, 4);

  static const int _firstPendingNumber = 55100;
  static const int _completedCount = 30;
  static const int _ratePerMinute = 12;

  static const Map<String, String> _phones = {
    'ZH10302': '+91 83349 44979',
    'ZH10304': '+91 82310 32532',
    'ZH10310': '+91 62409 33178',
    'ZH10313': '+91 81227 56832',
    'ZH10316': '+91 75106 32080',
    'ZH10319': '+91 76866 43110',
  };

  static String _phoneFor(String hostId) {
    if (_phones[hostId] case final phone?) return phone;
    for (final host in HostMockData.hosts) {
      if (host.hostId == hostId) return host.phone;
    }
    return AppStrings.emptyValue;
  }

  static const _PaymentHost _nandana = (
    name: 'Nandana',
    hostId: 'ZH10290',
    avatarIndex: 7,
    branchName: 'Bengaluru Indiranagar',
    accountHolderName: 'Nandana Suresh',
    accountNumber: '145439964558',
    ifscCode: 'UTIB0003759',
  );
  static const _PaymentHost _meera = (
    name: 'Meera',
    hostId: 'ZH10291',
    avatarIndex: 4,
    branchName: 'Kozhikode Mavoor Road',
    accountHolderName: 'Meera Krishnan',
    accountNumber: '994436213636',
    ifscCode: 'HDFC0003593',
  );
  static const _PaymentHost _neena = (
    name: 'Neena',
    hostId: 'ZH10292',
    avatarIndex: 1,
    branchName: 'Thrissur Round East',
    accountHolderName: 'Neena Thomas',
    accountNumber: '553343974472',
    ifscCode: 'FDRL0004522',
  );
  static const _PaymentHost _anjali = (
    name: 'Anjali',
    hostId: 'ZH10295',
    avatarIndex: 0,
    branchName: 'Coimbatore RS Puram',
    accountHolderName: 'Anjali Menon',
    accountNumber: '636831768929',
    ifscCode: 'HDFC0007891',
  );
  static const _PaymentHost _kavya = (
    name: 'Kavya',
    hostId: 'ZH10297',
    avatarIndex: 2,
    branchName: 'Kannur Fort Road',
    accountHolderName: 'Kavya Ramesh',
    accountNumber: '394636226348',
    ifscCode: 'FDRL0009176',
  );
  static const _PaymentHost _sneha = (
    name: 'Sneha',
    hostId: 'ZH10299',
    avatarIndex: 4,
    branchName: 'Bengaluru Indiranagar',
    accountHolderName: 'Sneha Pillai',
    accountNumber: '790730553796',
    ifscCode: 'HDFC0005135',
  );
  static const _PaymentHost _lakshmi = (
    name: 'Lakshmi',
    hostId: 'ZH10301',
    avatarIndex: 6,
    branchName: 'Kochi MG Road',
    accountHolderName: 'Lakshmi Priya',
    accountNumber: '778362247293',
    ifscCode: 'CNRB0001399',
  );
  static const _PaymentHost _swathy = (
    name: 'Swathy',
    hostId: 'ZH10302',
    avatarIndex: 7,
    branchName: 'Kochi MG Road',
    accountHolderName: 'Swathy Mohan',
    accountNumber: '184691600574',
    ifscCode: 'ICIC0002431',
  );
  static const _PaymentHost _malu = (
    name: 'Malu',
    hostId: 'ZH10304',
    avatarIndex: 1,
    branchName: 'Coimbatore RS Puram',
    accountHolderName: 'Malavika Varma',
    accountNumber: '367567674888',
    ifscCode: 'ICIC0001581',
  );
  static const _PaymentHost _ananya = (
    name: 'Ananya',
    hostId: 'ZH10305',
    avatarIndex: 2,
    branchName: 'Kannur Fort Road',
    accountHolderName: 'Ananya Reddy',
    accountNumber: '389546369463',
    ifscCode: 'UTIB0005387',
  );
  static const _PaymentHost _devika = (
    name: 'Devika',
    hostId: 'ZH10306',
    avatarIndex: 3,
    branchName: 'Thrissur Round East',
    accountHolderName: 'Devika Rajan',
    accountNumber: '811175085715',
    ifscCode: 'ICIC0001860',
  );
  static const _PaymentHost _divya = (
    name: 'Divya',
    hostId: 'ZH10309',
    avatarIndex: 6,
    branchName: 'Kochi MG Road',
    accountHolderName: 'Divya Bharathi',
    accountNumber: '721010303677',
    ifscCode: 'UTIB0009728',
  );
  static const _PaymentHost _keerthi = (
    name: 'Keerthi',
    hostId: 'ZH10310',
    avatarIndex: 7,
    branchName: 'Chennai T Nagar',
    accountHolderName: 'Keerthana R',
    accountNumber: '900625414630',
    ifscCode: 'FDRL0006118',
  );
  static const _PaymentHost _chinnu = (
    name: 'Chinnu',
    hostId: 'ZH10313',
    avatarIndex: 2,
    branchName: 'Madurai Anna Nagar',
    accountHolderName: 'Chinnu Mathew',
    accountNumber: '612094587731',
    ifscCode: 'HDFC0002814',
  );
  static const _PaymentHost _shalini = (
    name: 'Shalini',
    hostId: 'ZH10316',
    avatarIndex: 5,
    branchName: 'Kottayam Baker Junction',
    accountHolderName: 'Shalini Joseph',
    accountNumber: '458120937664',
    ifscCode: 'SBIN0007265',
  );
  static const _PaymentHost _ishu = (
    name: 'Ishu',
    hostId: 'ZH10319',
    avatarIndex: 0,
    branchName: 'Palakkad Stadium Road',
    accountHolderName: 'Ishwarya K',
    accountNumber: '273580164492',
    ifscCode: 'CNRB0004471',
  );

  static DateTime _nov(int day) => DateTime(2026, 11, day);

  static DateTime _oct(int day) => DateTime(2026, 10, day);

  static _WithdrawalFigures _figures(
    int callCount,
    int callMinutes,
    int amountEarned,
    int totalAmount,
  ) => (
    callCount: callCount,
    callMinutes: callMinutes,
    amountEarned: amountEarned,
    totalAmount: totalAmount,
  );

  static Withdrawal _withdrawal(
    String withdrawId,
    DateTime date,
    _PaymentHost host,
    _WithdrawalFigures figures, {
    DateTime? paidOn,
  }) => Withdrawal(
    withdrawId: withdrawId,
    date: date,
    hostName: host.name,
    hostId: host.hostId,
    phone: _phoneFor(host.hostId),
    avatarIndex: host.avatarIndex,
    callCount: figures.callCount,
    callMinutes: figures.callMinutes,
    amountEarned: figures.amountEarned,
    totalAmount: figures.totalAmount,
    branchName: host.branchName,
    accountHolderName: host.accountHolderName,
    accountNumber: host.accountNumber,
    ifscCode: host.ifscCode,
    status: paidOn == null
        ? WithdrawalStatus.pending
        : WithdrawalStatus.success,
    paidOn: paidOn,
    appliedTdsPercent: paidOn == null ? null : tdsPercent,
  );

  static List<Withdrawal> get _pendingWithdrawals {
    final requests = [
      (_nov(3), _nandana, _figures(101, 453, 5436, 5556)),
      (_nov(2), _meera, _figures(20, 791, 9492, 9552)),
      (_nov(4), _neena, _figures(35, 314, 5652, 5652)),
      (_nov(2), _anjali, _figures(155, 341, 6138, 6138)),
      (_nov(4), _kavya, _figures(117, 713, 8556, 8676)),
      (_nov(4), _sneha, _figures(20, 763, 9156, 9156)),
      (_nov(3), _lakshmi, _figures(129, 674, 8088, 8268)),
      (_nov(3), _swathy, _figures(78, 602, 10836, 11016)),
      (_nov(4), _malu, _figures(67, 272, 3264, 3444)),
      (_nov(3), _ananya, _figures(106, 620, 7440, 7440)),
      (_nov(2), _devika, _figures(25, 273, 4914, 5094)),
      (_nov(3), _divya, _figures(52, 780, 9360, 9420)),
      (_nov(4), _keerthi, _figures(132, 99, 1782, 1962)),
    ];
    return [
      for (final (index, (date, host, figures)) in requests.indexed)
        _withdrawal('WD${_firstPendingNumber + index}', date, host, figures),
    ];
  }

  static List<Withdrawal> get _completedWithdrawals {
    final paid = [
      (_oct(30), _keerthi, _figures(120, 1089, 13068, 13068)),
      (_oct(27), _chinnu, _figures(46, 243, 4374, 4494)),
      (_oct(25), _swathy, _figures(170, 76, 912, 972)),
      (_oct(24), _ishu, _figures(29, 658, 7896, 7956)),
      (_oct(20), _shalini, _figures(120, 131, 2358, 2478)),
      (_oct(20), _nandana, _figures(127, 266, 3192, 3192)),
      (_oct(18), _anjali, _figures(110, 349, 6282, 6342)),
      (_oct(14), _malu, _figures(121, 418, 5016, 5016)),
      (_oct(13), _ishu, _figures(70, 555, 6660, 6780)),
    ];
    const pool = [
      _meera,
      _kavya,
      _sneha,
      _lakshmi,
      _ananya,
      _devika,
      _divya,
      _neena,
      _chinnu,
      _shalini,
    ];
    final generated = [
      for (var i = 0; i < _completedCount - paid.length; i++)
        (
          _oct(12 - i ~/ 2),
          pool[i % pool.length],
          _figures(
            24 + (i * 17) % 150,
            160 + (i * 53) % 640,
            (160 + (i * 53) % 640) * _ratePerMinute,
            (160 + (i * 53) % 640) * _ratePerMinute +
                (i.isEven ? 0 : 60 + (i % 3) * 60),
          ),
        ),
    ];
    return [
      for (final (index, (paidOn, host, figures)) in [
        ...paid,
        ...generated,
      ].indexed)
        _withdrawal(
          'WD${_firstPendingNumber - 1 - index}',
          paidOn.subtract(const Duration(days: 1)),
          host,
          figures,
          paidOn: paidOn,
        ),
    ];
  }

  static final List<Withdrawal> withdrawals = [
    ..._pendingWithdrawals,
    ..._completedWithdrawals,
  ];
}
