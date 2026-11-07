import 'package:zuno_admin_dashboard/core/utils/name_formatter.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/host_profile_options.dart';

enum HostRequestStatus { pending, approved, rejected }

class HostRequest {
  const HostRequest({
    required this.requestId,
    required this.submittedOn,
    required this.realName,
    required this.nickName,
    required this.phone,
    required this.dateOfBirth,
    required this.city,
    required this.gender,
    required this.languages,
    required this.maskedAadhaar,
    required this.avatarIndex,
    this.status = HostRequestStatus.pending,
    this.aadhaarImageUrl,
    this.selfieImageUrl,
  });

  final String requestId;
  final DateTime submittedOn;
  final String realName;
  final String nickName;
  final String phone;
  final DateTime dateOfBirth;
  final String city;
  final HostGender gender;
  final List<HostLanguage> languages;
  final String maskedAadhaar;
  final int avatarIndex;
  final HostRequestStatus status;
  final String? aadhaarImageUrl;
  final String? selfieImageUrl;

  String get initials => NameFormatter.initials(realName);

  bool get isPending => status == HostRequestStatus.pending;

  HostRequest copyWith({
    String? realName,
    String? nickName,
    String? phone,
    DateTime? dateOfBirth,
    String? city,
    HostGender? gender,
    List<HostLanguage>? languages,
    HostRequestStatus? status,
  }) {
    return HostRequest(
      requestId: requestId,
      submittedOn: submittedOn,
      realName: realName ?? this.realName,
      nickName: nickName ?? this.nickName,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      city: city ?? this.city,
      gender: gender ?? this.gender,
      languages: languages ?? this.languages,
      maskedAadhaar: maskedAadhaar,
      avatarIndex: avatarIndex,
      status: status ?? this.status,
      aadhaarImageUrl: aadhaarImageUrl,
      selfieImageUrl: selfieImageUrl,
    );
  }
}
