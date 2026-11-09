import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/enums/app_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_badge.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/admin_host.dart';

class HostStatusBadges extends StatelessWidget {
  const HostStatusBadges({super.key, required this.host});

  static const double _gap = 6;

  final AdminHost host;

  (String, AppStatus) get _status => switch (host.status) {
    HostStatus.active => (AppStrings.active, AppStatus.active),
    HostStatus.inactive => (AppStrings.inactive, AppStatus.inactive),
    HostStatus.blocked => (AppStrings.blocked, AppStatus.blocked),
    HostStatus.deletedByAdmin => (AppStrings.deletedByAdmin, AppStatus.error),
    HostStatus.deletedByUser => (AppStrings.deletedByUser, AppStatus.inactive),
  };

  @override
  Widget build(BuildContext context) {
    final (label, status) = _status;

    return Wrap(
      spacing: _gap,
      runSpacing: AppUtils.spacingXs,
      children: [
        AppStatusBadge(label: label, status: status),
        if (host.isNew)
          const AppStatusBadge(
            label: AppStrings.newLabel,
            status: AppStatus.isNew,
          ),
      ],
    );
  }
}
