import 'package:zuno_admin_dashboard/core/utils/name_formatter.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/host_profile_options.dart';

enum ProfilePhotoStatus { pending, accepted, rejected }

class ProfilePhotoRequest {
  const ProfilePhotoRequest({
    required this.requestId,
    required this.submittedOn,
    required this.hostName,
    required this.hostId,
    required this.realName,
    required this.city,
    required this.languages,
    required this.avatarIndex,
    this.photoUrl,
    this.status = ProfilePhotoStatus.pending,
    this.isDeciding = false,
    this.approvedAt,
    this.approvedBy,
    String? userID,
  }) : userID = userID ?? hostId;

  final String requestId;
  final DateTime submittedOn;
  final String hostName;
  final String hostId;
  final String userID;
  final String realName;
  final String city;
  final List<HostLanguage> languages;
  final int avatarIndex;
  final String? photoUrl;
  final ProfilePhotoStatus status;
  final bool isDeciding;
  final DateTime? approvedAt;
  final String? approvedBy;

  String get initials => NameFormatter.initials(hostName);

  bool get isPending => status == ProfilePhotoStatus.pending;

  ProfilePhotoRequest copyWith({ProfilePhotoStatus? status, bool? isDeciding}) {
    return ProfilePhotoRequest(
      requestId: requestId,
      submittedOn: submittedOn,
      hostName: hostName,
      hostId: hostId,
      userID: userID,
      realName: realName,
      city: city,
      languages: languages,
      avatarIndex: avatarIndex,
      photoUrl: photoUrl,
      status: status ?? this.status,
      isDeciding: isDeciding ?? this.isDeciding,
      approvedAt: approvedAt,
      approvedBy: approvedBy,
    );
  }
}
