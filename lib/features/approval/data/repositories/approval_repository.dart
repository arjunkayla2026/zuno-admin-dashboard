import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/core/data/users_remote_data_source.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/host_request.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/host_profile_options.dart';

class ApprovalRepository {
  const ApprovalRepository(this._dataSource);

  final UsersRemoteDataSource _dataSource;

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

  Future<Either<Failure, List<HostRequest>>> fetchHostRequests() async {
    final result = await _dataSource.fetchHostApplicants();
    return result.map(
      (records) => [
        for (final record in records)
          if (record.hostDetails.isNotEmpty) _toRequest(record),
      ],
    );
  }

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
  ) => _dataSource.decideHostRequest(
    request.requestId,
    approved: decision == HostRequestStatus.approved,
  );

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
      submittedOn: _submittedOn(record),
      realName: realName,
      nickName:
          record.userName ??
          UserRecord.readText(details['userName']) ??
          AppStrings.emptyValue,
      phone: record.phoneLabel,
      dateOfBirth: DateTime.tryParse(UserRecord.readText(details['dob']) ?? ''),
      city:
          UserRecord.readText(details['district']) ??
          UserRecord.readText(details['state']) ??
          AppStrings.emptyValue,
      gender: _optionNamed(HostGender.values, details['gender']),
      languages: _languages(details['languages']),
      maskedAadhaar: AppStrings.emptyValue,
      avatarIndex: record.avatarIndex,
      status: switch (details['hostStatus']) {
        UserRecord.documentApproved => HostRequestStatus.approved,
        UserRecord.documentRejected => HostRequestStatus.rejected,
        _ => HostRequestStatus.pending,
      },
      documents: documents,
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
