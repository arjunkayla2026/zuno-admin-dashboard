import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/record_page.dart';
import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/core/data/users_remote_data_source.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/approval/data/datasources/avatar_storage_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/host_request.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/profile_photo_request.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/host_profile_options.dart';

class ApprovalRepository {
  const ApprovalRepository(this._dataSource, {this._avatars});

  final UsersRemoteDataSource _dataSource;
  final AvatarStorageRemoteDataSource? _avatars;

  static String _fieldOf(HostDocumentType type) => switch (type) {
    HostDocumentType.aadhaarFront => UserRecord.aadhaarFrontField,
    HostDocumentType.aadhaarBack => UserRecord.aadhaarBackField,
    HostDocumentType.selfie => UserRecord.selfieField,
  };

  static String _statusValue(HostRequestStatus decision) => switch (decision) {
    HostRequestStatus.approved => UserRecord.documentApproved,
    HostRequestStatus.rejected => UserRecord.documentRejected,
    HostRequestStatus.pending => UserRecord.documentSubmitted,
  };

  Future<Either<Failure, RecordPage<HostRequest>>> fetchHostRequests(
    RecordPageQuery query,
  ) async {
    final result = await _dataSource.fetchHostApplicants(query);
    return result.map(
      (page) => page.mapItems(
        (records) => [
          for (final record in records)
            if (record.hostDetails.isNotEmpty) _toRequest(record),
        ],
      ),
    );
  }

  Future<Either<Failure, int>> countHostRequests(RecordPageQuery query) =>
      _dataSource.countHostApplicants(query);

  Future<Either<Failure, Unit>> reviewDocument(
    HostRequest request,
    HostDocumentType type,
    HostRequestStatus decision,
  ) => _dataSource.reviewHostDocument(
    request.requestId,
    document: _fieldOf(type),
    status: _statusValue(decision),
  );

  Future<Either<Failure, Unit>> decideRequest(
    HostRequest request,
    HostRequestStatus decision,
  ) async {
    final approved = decision == HostRequestStatus.approved;
    final result = await _dataSource.decideHostRequest(
      request.requestId,
      approved: approved,
    );
    if (approved && result.isRight()) {
      await _assignDefaultAvatar(request.requestId);
    }
    return result;
  }

  Future<void> _assignDefaultAvatar(String userId) async {
    final avatars = _avatars;
    if (avatars == null) return;

    final records = await _dataSource.fetchByIds([userId]);
    final record = records.getOrElse((_) => const []).firstOrNull;
    if (record == null || record.hasCustomAvatar) return;

    final gender = _optionNamed(
      HostGender.values,
      record.hostDetails[UserRecord.genderField],
    );
    final folder = switch (gender) {
      HostGender.male => UserRecord.maleAvatarFolder,
      HostGender.female => UserRecord.femaleAvatarFolder,
      HostGender.other || null => null,
    };
    if (folder == null) return;

    final picked = await avatars.pickRandomAvatarUrl(
      folder,
      avoidUrl: record.avatarImageUrl,
    );
    if (picked case Right(value: final avatarUrl)) {
      await _dataSource.assignDefaultAvatar(
        userId,
        avatarUrl: avatarUrl,
        previousUrl: record.avatarImageUrl,
      );
    }
  }

  Future<Either<Failure, RecordPage<ProfilePhotoRequest>>>
  fetchProfilePhotoRequests(RecordPageQuery query) async {
    final result = await _dataSource.fetchProfilePhotoRequests(query);
    return result.map(
      (page) => page.mapItems(
        (records) => [
          for (final record in records)
            if (record.hasValidSubmittedImage) _toProfilePhoto(record),
        ],
      ),
    );
  }

  Future<Either<Failure, int>> countProfilePhotoRequests(
    RecordPageQuery query,
  ) => _dataSource.countProfilePhotoRequests(query);

  Future<Either<Failure, Unit>> decideProfilePhoto(
    ProfilePhotoRequest request,
    ProfilePhotoStatus decision,
  ) async {
    final reviewedUrl = request.photoUrl;
    if (reviewedUrl == null) {
      return left(const DataFailure(AppStrings.profilePhotoChanged));
    }
    return _dataSource.decideProfilePhoto(
      request.requestId,
      approved: decision == ProfilePhotoStatus.accepted,
      reviewedUrl: reviewedUrl,
    );
  }

  ProfilePhotoRequest _toProfilePhoto(UserRecord record) {
    final details = record.hostDetails;
    final displayName = record.hostUserName ?? AppStrings.emptyValue;

    return ProfilePhotoRequest(
      requestId: record.id,
      submittedOn: record.updatedAt ?? record.createdAt ?? DateTime.now(),
      hostName: displayName,
      hostId: record.id,
      userID: record.userIDLabel,
      realName:
          UserRecord.readText(details['fullName']) ??
          record.name ??
          displayName,
      city:
          UserRecord.readText(details['district']) ??
          UserRecord.readText(details['state']) ??
          AppStrings.emptyValue,
      languages: _languages(details['languages']),
      avatarIndex: record.avatarIndex,
      photoUrl: record.submittedImageUrl,
      approvedAt: record.avatarApprovedAt,
      approvedBy: record.avatarApprovedBy,
    );
  }

  HostRequest _toRequest(UserRecord record) {
    final details = record.hostDetails;
    final realName =
        UserRecord.readText(details['fullName']) ??
        record.name ??
        record.userName ??
        AppStrings.emptyValue;
    final documents = [
      for (final type in HostDocumentType.values) _toDocument(type, details),
    ];

    return HostRequest(
      requestId: record.id,
      userID: record.userIDLabel,
      submittedOn: _submittedOn(record),
      realName: realName,
      nickName: record.hostUserName ?? AppStrings.emptyValue,
      phone: record.phoneLabel,
      dateOfBirth: DateTime.tryParse(UserRecord.readText(details['dob']) ?? ''),
      city:
          UserRecord.readText(details['district']) ??
          UserRecord.readText(details['state']) ??
          AppStrings.emptyValue,
      gender: _optionNamed(HostGender.values, details[UserRecord.genderField]),
      languages: _languages(details['languages']),
      maskedAadhaar: AppStrings.emptyValue,
      avatarIndex: record.avatarIndex,
      status: switch (details['hostStatus']) {
        UserRecord.documentApproved => HostRequestStatus.approved,
        UserRecord.documentRejected => HostRequestStatus.rejected,
        _ => HostRequestStatus.pending,
      },
      documents: documents,
      approvedAt: record.hostApprovedAt,
      approvedBy: record.hostApprovedBy,
    );
  }

  HostDocument _toDocument(
    HostDocumentType type,
    Map<String, dynamic> details,
  ) {
    final entry = details[_fieldOf(type)];
    final value = entry is Map ? entry[UserRecord.documentStatusField] : null;
    final status = switch (value) {
      UserRecord.documentSubmitted => HostRequestStatus.pending,
      UserRecord.documentApproved => HostRequestStatus.approved,
      UserRecord.documentRejected => HostRequestStatus.rejected,
      _ => null,
    };

    return HostDocument(
      type: type,
      imageUrl: entry is Map ? UserRecord.readText(entry['url']) : null,
      status: status ?? HostRequestStatus.pending,
      isAvailable: status != null,
    );
  }

  DateTime _submittedOn(UserRecord record) {
    final front = record.hostDetails[UserRecord.aadhaarFrontField];
    final uploaded = front is Map
        ? DateTime.tryParse(UserRecord.readText(front['uploadedDate']) ?? '')
        : null;
    return uploaded ?? record.createdAt ?? DateTime.now();
  }

  T? _optionNamed<T extends Enum>(List<T> options, Object? value) =>
      value is String ? options.asNameMap()[value.toLowerCase()] : null;

  List<HostLanguage> _languages(Object? value) {
    if (value is! List) return const [];
    return [for (final item in value) ?_optionNamed(HostLanguage.values, item)];
  }
}
