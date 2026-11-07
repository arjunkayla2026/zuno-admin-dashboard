import 'package:zuno_admin_dashboard/features/host_management/data/models/admin_host.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/call_pricing.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/host_profile_options.dart';

abstract final class HostMockData {
  static const CallPricing pricing = CallPricing(
    audioPerSecond: 1,
    videoPerSecond: 2,
    perMessage: 2,
  );

  static const int _totalHosts = 30;
  static const int _firstHostNumber = 10290;

  static final List<AdminHost> _screenshotHosts = [
    AdminHost(
      createdDate: '09 Aug 2026',
      name: 'Nandana',
      fullName: 'Nandana Suresh',
      hostId: 'ZH10290',
      phone: '+91 89822 97632',
      walletBalance: 2818,
      status: HostStatus.active,
      avatarIndex: 7,
      dateOfBirth: DateTime(2000, 12, 22),
      district: 'Mysuru',
      state: 'Karnataka',
      gender: HostGender.female,
      motherTongue: HostLanguage.hindi,
      languages: const {HostLanguage.english, HostLanguage.kannada},
    ),
    AdminHost(
      createdDate: '08 Jun 2026',
      name: 'Meera',
      fullName: 'Meera Krishnan',
      hostId: 'ZH10291',
      phone: '+91 65470 34508',
      walletBalance: 178,
      status: HostStatus.active,
      avatarIndex: 4,
    ),
    AdminHost(
      createdDate: '03 Oct 2026',
      name: 'Neena',
      fullName: 'Neena Thomas',
      hostId: 'ZH10292',
      phone: '+91 66146 89825',
      walletBalance: 3237,
      status: HostStatus.active,
      avatarIndex: 1,
    ),
    AdminHost(
      createdDate: '23 Apr 2026',
      name: 'Jenniffer',
      fullName: 'Jenniffer Mary',
      hostId: 'ZH10293',
      phone: '+91 82327 63289',
      walletBalance: 489,
      status: HostStatus.inactive,
      avatarIndex: 5,
    ),
    AdminHost(
      createdDate: '29 Mar 2026',
      name: 'Pinkky',
      fullName: 'Pinkky Raj',
      hostId: 'ZH10294',
      phone: '+91 94614 15287',
      walletBalance: 741,
      status: HostStatus.blocked,
      avatarIndex: 3,
    ),
    AdminHost(
      createdDate: '11 May 2026',
      name: 'Anjali',
      fullName: 'Anjali Menon',
      hostId: 'ZH10295',
      phone: '+91 64219 17834',
      walletBalance: 530,
      status: HostStatus.active,
      avatarIndex: 0,
    ),
    AdminHost(
      createdDate: '01 Sep 2026',
      name: 'Diya',
      fullName: 'Diya Nair',
      hostId: 'ZH10296',
      phone: '+91 97858 28051',
      walletBalance: 3790,
      status: HostStatus.deletedByAdmin,
      avatarIndex: 1,
    ),
    AdminHost(
      createdDate: '02 Nov 2026',
      name: 'Kavya',
      fullName: 'Kavya Ramesh',
      hostId: 'ZH10297',
      phone: '+91 94448 29657',
      walletBalance: 2917,
      status: HostStatus.active,
      avatarIndex: 2,
      isNew: true,
    ),
    AdminHost(
      createdDate: '04 Aug 2026',
      name: 'Riya',
      fullName: 'Riya Joseph',
      hostId: 'ZH10298',
      phone: '+91 78535 40520',
      walletBalance: 4762,
      status: HostStatus.deletedByUser,
      avatarIndex: 3,
    ),
    AdminHost(
      createdDate: '20 May 2026',
      name: 'Sneha',
      fullName: 'Sneha Pillai',
      hostId: 'ZH10299',
      phone: '+91 89209 68801',
      walletBalance: 1633,
      status: HostStatus.active,
      avatarIndex: 4,
    ),
    AdminHost(
      createdDate: '04 Jul 2026',
      name: 'Aishu',
      fullName: 'Aishwarya Lakshmi',
      hostId: 'ZH10300',
      phone: '+91 87231 94191',
      walletBalance: 3506,
      status: HostStatus.inactive,
      avatarIndex: 5,
    ),
    AdminHost(
      createdDate: '28 Jun 2026',
      name: 'Lakshmi',
      fullName: 'Lakshmi Priya',
      hostId: 'ZH10301',
      phone: '+91 91390 60793',
      walletBalance: 1836,
      status: HostStatus.active,
      avatarIndex: 6,
    ),
  ];

  static final List<AdminHost> hosts = [
    ..._screenshotHosts,
    for (var i = _screenshotHosts.length; i < _totalHosts; i++)
      AdminHost(
        createdDate: '01 Jun 2026',
        name: 'Host ${i + 1}',
        fullName: 'Test Host ${i + 1}',
        hostId: 'ZH${_firstHostNumber + i}',
        phone: '+91 90000 ${20000 + i}',
        walletBalance: 0,
        status: HostStatus.active,
        avatarIndex: i,
      ),
  ];
}
