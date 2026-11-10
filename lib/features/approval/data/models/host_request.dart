import 'package:zuno_admin_dashboard/core/utils/name_formatter.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/host_profile_options.dart';

enum HostRequestStatus { pending, approved, rejected }

enum HostDocumentType { aadhaarFront, aadhaarBack, selfie }

class HostDocument {
  const HostDocument({
    required this.type,
    this.imageUrl,
    this.status = HostRequestStatus.pending,
    this.isAvailable = true,
  });

  final HostDocumentType type;
  final String? imageUrl;
  final HostRequestStatus status;
  final bool isAvailable;

  bool get canReview => isAvailable && status == HostRequestStatus.pending;

  HostDocument withStatus(HostRequestStatus status) => HostDocument(
    type: type,
    imageUrl: imageUrl,
    status: status,
    isAvailable: isAvailable,
  );
}

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
    this.documents = const [],
    this.approvedAt,
    this.approvedBy,
    String? userID,
  }) : userID = userID ?? requestId;

  final String requestId;
  final String userID;
  final DateTime submittedOn;
  final String realName;
  final String nickName;
  final String phone;
  final DateTime? dateOfBirth;
  final String city;
  final HostGender? gender;
  final List<HostLanguage> languages;
  final String maskedAadhaar;
  final int avatarIndex;
  final HostRequestStatus status;
  final List<HostDocument> documents;
  final DateTime? approvedAt;
  final String? approvedBy;

  String get initials => NameFormatter.initials(realName);

  bool get isPending => status == HostRequestStatus.pending;

  bool get canDecide =>
      isPending &&
      documents.isNotEmpty &&
      documents.every((doc) => doc.status == HostRequestStatus.approved);

  HostRequest withDocumentStatus(
    HostDocumentType type,
    HostRequestStatus decision,
  ) {
    return copyWith(
      documents: [
        for (final document in documents)
          document.type == type ? document.withStatus(decision) : document,
      ],
    );
  }

  HostRequest copyWith({
    String? realName,
    String? nickName,
    String? phone,
    DateTime? dateOfBirth,
    String? city,
    HostGender? gender,
    List<HostLanguage>? languages,
    HostRequestStatus? status,
    List<HostDocument>? documents,
  }) {
    return HostRequest(
      requestId: requestId,
      userID: userID,
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
      documents: documents ?? this.documents,
      approvedAt: approvedAt,
      approvedBy: approvedBy,
    );
  }
}
