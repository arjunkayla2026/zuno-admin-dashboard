import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_detail_grid.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/host_request.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/host_request_labels.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/widgets/host_profile_labels.dart';

class HostRequestDetailsView extends StatelessWidget {
  const HostRequestDetailsView({super.key, required this.request});

  static const int _columns = 3;
  static const double _rowGap = 12;

  final HostRequest request;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppDetailGrid(
          columns: _columns,
          items: [
            AppDetailItem(AppStrings.realName, value: request.realName),
            AppDetailItem(AppStrings.nickName, value: request.nickName),
            AppDetailItem(AppStrings.mobileNumber, value: request.phone),
            AppDetailItem(
              AppStrings.dateOfBirth,
              value: DateFormatter.short(request.dateOfBirth),
            ),
            AppDetailItem(AppStrings.city, value: request.city),
            AppDetailItem(
              AppStrings.gender,
              value: HostProfileLabels.gender(request.gender),
            ),
          ],
        ),
        const SizedBox(height: _rowGap),
        AppDetailGrid(
          columns: 1,
          items: [
            AppDetailItem(
              AppStrings.speakLanguages,
              value: HostRequestLabels.languages(request),
            ),
          ],
        ),
      ],
    );
  }
}
