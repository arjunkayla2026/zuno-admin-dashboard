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
  });

  final String requestId;
  final DateTime submittedOn;
  final String hostName;
  final String hostId;
  final String realName;
  final String city;
  final List<HostLanguage> languages;
  final int avatarIndex;
  final String? photoUrl;
  final ProfilePhotoStatus status;

  String get initials => NameFormatter.initials(hostName);

  bool get isPending => status == ProfilePhotoStatus.pending;

  ProfilePhotoRequest copyWith({ProfilePhotoStatus? status}) {
    return ProfilePhotoRequest(
      requestId: requestId,
      submittedOn: submittedOn,
      hostName: hostName,
      hostId: hostId,
      realName: realName,
      city: city,
      languages: languages,
      avatarIndex: avatarIndex,
      photoUrl: photoUrl,
      status: status ?? this.status,
    );
  }
}
