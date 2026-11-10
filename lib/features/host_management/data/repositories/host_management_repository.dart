import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/core/data/users_remote_data_source.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/admin_host.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/host_profile_options.dart';

class HostManagementRepository {
  const HostManagementRepository(this._dataSource);

  static const String _role = 'host';
  static const String _details = 'hostDetails';

  final UsersRemoteDataSource _dataSource;

  Future<Either<Failure, List<AdminHost>>> fetchHosts() async {
    final result = await _dataSource.fetchByRole(_role);
    return result.map((records) => records.map(_toAdminHost).toList());
  }

  Future<Either<Failure, Unit>> updateDetails(
    AdminHost original,
    AdminHost edited,
  ) async {
    final phoneFields = edited.phone == original.phone
        ? const <String, Object?>{}
        : UserRecord.phoneFields(edited.phone);
    if (phoneFields == null) {
      return left(const DataFailure(AppStrings.enterValidPhone));
    }

    return _dataSource.updateRecord(original.hostId, {
      if (edited.name != original.name) ...{
        'userName': edited.name,
        '$_details.userName': edited.name,
      },
      if (edited.fullName != original.fullName)
        '$_details.fullName': edited.fullName,
      if (edited.district != original.district)
        '$_details.district': edited.district,
      if (edited.state != original.state) '$_details.state': edited.state,
      if (edited.dateOfBirth != original.dateOfBirth)
        '$_details.dob': edited.dateOfBirth?.toIso8601String(),
      if (edited.gender != original.gender)
        '$_details.gender': edited.gender?.name,
      if (edited.motherTongue != original.motherTongue)
        '$_details.motherTongue': edited.motherTongue?.name,
      if (!setEquals(edited.languages, original.languages))
        '$_details.languages': [
          for (final language in edited.languages) language.name,
        ],
      ...phoneFields,
    });
  }

  Future<Either<Failure, Unit>> setBlocked(
    AdminHost host, {
    required bool blocked,
  }) => _dataSource.setBlocked(host.hostId, blocked: blocked);

  Future<Either<Failure, Unit>> delete(AdminHost host) =>
      _dataSource.markDeletedByAdmin(host.hostId);

  AdminHost _toAdminHost(UserRecord record) {
    final details = record.hostDetails;
    final name =
        record.userName ??
        UserRecord.readText(details['userName']) ??
        record.name ??
        AppStrings.emptyValue;

    return AdminHost(
      createdDate: record.createdDateLabel,
      name: name,
      fullName: UserRecord.readText(details['fullName']) ?? name,
      hostId: record.id,
      userID: record.userIDLabel,
      phone: record.phoneLabel,
      walletBalance: record.walletBalance.truncate(),
      status: statusOf(record),
      avatarIndex: record.avatarIndex,
      isNew: record.isNewAccount,
      isAccountActive: record.isActive,
      dateOfBirth: DateTime.tryParse(UserRecord.readText(details['dob']) ?? ''),
      district: UserRecord.readText(details['district']) ?? '',
      state: UserRecord.readText(details['state']) ?? '',
      gender: _optionNamed(HostGender.values, details['gender']),
      motherTongue: _optionNamed(HostLanguage.values, details['motherTongue']),
      languages: _languages(details['languages']),
      aadhaarImageUrl: _documentUrl(details['aadharFrontPreview']),
      selfieImageUrl: _documentUrl(details['selfiPreview']),
    );
  }

  static HostStatus statusOf(UserRecord record) {
    if (record.isDeleted) {
      return record.isDeletedByAdmin
          ? HostStatus.deletedByAdmin
          : HostStatus.deletedByUser;
    }
    if (record.isBlocked) return HostStatus.blocked;
    return record.isActive ? HostStatus.active : HostStatus.inactive;
  }

  T? _optionNamed<T extends Enum>(List<T> options, Object? value) =>
      value is String ? options.asNameMap()[value.toLowerCase()] : null;

  Set<HostLanguage> _languages(Object? value) {
    if (value is! List) return const {};
    return {for (final item in value) ?_optionNamed(HostLanguage.values, item)};
  }

  String? _documentUrl(Object? value) =>
      value is Map ? UserRecord.readText(value['url']) : null;
}
