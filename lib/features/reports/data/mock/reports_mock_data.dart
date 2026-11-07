import 'package:zuno_admin_dashboard/features/reports/data/models/user_report.dart';

abstract final class ReportsMockData {
  static final DateTime today = DateTime(2026, 11, 4);

  static const ReportPartyRole _user = ReportPartyRole.user;
  static const ReportPartyRole _host = ReportPartyRole.host;

  static const ReportParty _aishu = ReportParty(
    name: 'Aishu',
    id: 'ZH10300',
    role: _host,
    avatarIndex: 5,
  );
  static const ReportParty _sachin = ReportParty(
    name: 'Sachin Paul',
    id: 'ZU10241',
    role: _user,
    avatarIndex: 0,
  );
  static const ReportParty _naveen = ReportParty(
    name: 'Naveen Reddy',
    id: 'ZU10242',
    role: _user,
    avatarIndex: 6,
  );
  static const ReportParty _devika = ReportParty(
    name: 'Devika',
    id: 'ZH10306',
    role: _host,
    avatarIndex: 3,
  );
  static const ReportParty _abhijith = ReportParty(
    name: 'Abhijith S',
    id: 'ZU10243',
    role: _user,
    avatarIndex: 7,
  );
  static const ReportParty _anjali = ReportParty(
    name: 'Anjali',
    id: 'ZH10295',
    role: _host,
    avatarIndex: 0,
  );
  static const ReportParty _rahul = ReportParty(
    name: 'Rahul Menon',
    id: 'ZU10232',
    role: _user,
    avatarIndex: 1,
  );
  static const ReportParty _sneha = ReportParty(
    name: 'Sneha',
    id: 'ZH10299',
    role: _host,
    avatarIndex: 4,
  );
  static const ReportParty _suhail = ReportParty(
    name: 'Suhail Ahmed',
    id: 'ZU10244',
    role: _user,
    avatarIndex: 3,
  );
  static const ReportParty _malu = ReportParty(
    name: 'Malu',
    id: 'ZH10304',
    role: _host,
    avatarIndex: 1,
  );
  static const ReportParty _nikhil = ReportParty(
    name: 'Nikhil Jose',
    id: 'ZU10245',
    role: _user,
    avatarIndex: 6,
  );
  static const ReportParty _lakshmi = ReportParty(
    name: 'Lakshmi',
    id: 'ZH10301',
    role: _host,
    avatarIndex: 6,
  );
  static const ReportParty _sreejith = ReportParty(
    name: 'Sreejith P',
    id: 'ZU10246',
    role: _user,
    avatarIndex: 0,
  );
  static const ReportParty _bibin = ReportParty(
    name: 'Bibin George',
    id: 'ZU10247',
    role: _user,
    avatarIndex: 1,
  );
  static const ReportParty _nila = ReportParty(
    name: 'Nila',
    id: 'ZH10307',
    role: _host,
    avatarIndex: 4,
  );
  static const ReportParty _arjun = ReportParty(
    name: 'Arjun Nair',
    id: 'ZU10231',
    role: _user,
    avatarIndex: 0,
  );
  static const ReportParty _divya = ReportParty(
    name: 'Divya',
    id: 'ZH10308',
    role: _host,
    avatarIndex: 6,
  );
  static const ReportParty _salman = ReportParty(
    name: 'Salman Faris',
    id: 'ZU10248',
    role: _user,
    avatarIndex: 3,
  );
  static const ReportParty _ananya = ReportParty(
    name: 'Ananya',
    id: 'ZH10305',
    role: _host,
    avatarIndex: 2,
  );
  static const ReportParty _midhun = ReportParty(
    name: 'Midhun Raj',
    id: 'ZU10249',
    role: _user,
    avatarIndex: 4,
  );

  static const int _totalReports = 29;

  static UserReport _report(
    DateTime date,
    ReportParty reportedBy,
    ReportParty reported,
    ReportType type,
    int totalReports,
  ) => UserReport(
    date: date,
    reportedBy: reportedBy,
    reported: reported,
    type: type,
    totalReports: totalReports,
  );

  static List<UserReport> _buildReports() {
    final nov4 = DateTime(2026, 11, 4);
    final nov3 = DateTime(2026, 11, 3);
    final nov1 = DateTime(2026, 11, 1);
    final oct31 = DateTime(2026, 10, 31);
    final screenshot = [
      _report(nov4, _aishu, _sachin, ReportType.fakeProfile, 2),
      _report(nov4, _naveen, _devika, ReportType.harassment, 4),
      _report(nov4, _abhijith, _anjali, ReportType.harassment, 4),
      _report(nov4, _rahul, _sneha, ReportType.fakeProfile, 3),
      _report(nov4, _suhail, _devika, ReportType.fakeProfile, 4),
      _report(nov3, _malu, _nikhil, ReportType.harassment, 5),
      _report(nov3, _lakshmi, _sreejith, ReportType.harassment, 5),
      _report(nov3, _nikhil, _anjali, ReportType.harassment, 4),
      _report(nov3, _bibin, _nila, ReportType.other, 3),
      _report(nov1, _arjun, _divya, ReportType.abusiveLanguage, 2),
      _report(nov1, _salman, _nila, ReportType.harassment, 3),
      _report(oct31, _ananya, _midhun, ReportType.other, 1),
    ];

    const users = [_sachin, _naveen, _rahul, _bibin, _arjun, _salman];
    const hosts = [_anjali, _sneha, _devika, _nila, _divya, _malu];
    const types = ReportType.values;

    return [
      ...screenshot,
      for (var i = 0; i < _totalReports - screenshot.length; i++)
        i.isEven
            ? _report(
                oct31.subtract(Duration(days: 1 + i ~/ 2)),
                users[i % users.length],
                hosts[(i * 5) % hosts.length],
                types[i % types.length],
                1 + i % 4,
              )
            : _report(
                oct31.subtract(Duration(days: 1 + i ~/ 2)),
                hosts[i % hosts.length],
                users[(i * 5) % users.length],
                types[i % types.length],
                1 + i % 3,
              ),
    ];
  }

  static final List<UserReport> reports = _buildReports();
}
