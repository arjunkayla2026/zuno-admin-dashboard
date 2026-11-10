import 'package:zuno_admin_dashboard/core/utils/name_formatter.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/host_profile_options.dart';

enum HostStatus { active, inactive, blocked, deletedByAdmin, deletedByUser }

class AdminHost {
  const AdminHost({
    required this.createdDate,
    required this.name,
    required this.fullName,
    required this.hostId,
    required this.phone,
    required this.walletBalance,
    required this.status,
    required this.avatarIndex,
    this.isNew = false,
    this.isAccountActive = true,
    this.dateOfBirth,
    this.district = '',
    this.state = '',
    this.gender,
    this.motherTongue,
    this.languages = const {},
    this.aadhaarImageUrl,
    this.selfieImageUrl,
    String? userID,
  }) : userID = userID ?? hostId;

  final String createdDate;
  final String name;
  final String fullName;
  final String hostId;
  final String userID;
  final String phone;
  final int walletBalance;
  final HostStatus status;
  final int avatarIndex;
  final bool isNew;
  final bool isAccountActive;
  final DateTime? dateOfBirth;
  final String district;
  final String state;
  final HostGender? gender;
  final HostLanguage? motherTongue;
  final Set<HostLanguage> languages;
  final String? aadhaarImageUrl;
  final String? selfieImageUrl;

  String get initials => NameFormatter.initials(name);

  bool get hasActions =>
      status != HostStatus.deletedByAdmin && status != HostStatus.deletedByUser;

  AdminHost copyWith({
    String? name,
    String? fullName,
    String? phone,
    int? walletBalance,
    HostStatus? status,
    DateTime? dateOfBirth,
    String? district,
    String? state,
    HostGender? gender,
    HostLanguage? motherTongue,
    Set<HostLanguage>? languages,
  }) {
    return AdminHost(
      createdDate: createdDate,
      name: name ?? this.name,
      fullName: fullName ?? this.fullName,
      hostId: hostId,
      userID: userID,
      phone: phone ?? this.phone,
      walletBalance: walletBalance ?? this.walletBalance,
      status: status ?? this.status,
      avatarIndex: avatarIndex,
      isNew: isNew,
      isAccountActive: isAccountActive,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      district: district ?? this.district,
      state: state ?? this.state,
      gender: gender ?? this.gender,
      motherTongue: motherTongue ?? this.motherTongue,
      languages: languages ?? this.languages,
      aadhaarImageUrl: aadhaarImageUrl,
      selfieImageUrl: selfieImageUrl,
    );
  }
}
