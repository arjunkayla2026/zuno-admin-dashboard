import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_data_table.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_initials_avatar.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_badge.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/host_request.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/host_request_flow.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/host_request_labels.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/widgets/host_profile_labels.dart';

class HostRequestsTable extends StatelessWidget {
  const HostRequestsTable({super.key, required this.requests});

  static const List<AppTableColumn> _columns = [
    AppTableColumn(AppStrings.date, 137),
    AppTableColumn(AppStrings.realName, 196),
    AppTableColumn(AppStrings.nickName, 102),
    AppTableColumn(AppStrings.mobileNumber, 166),
    AppTableColumn(AppStrings.dateOfBirth, 124),
    AppTableColumn(AppStrings.city, 148),
    AppTableColumn(AppStrings.gender, 82),
    AppTableColumn(AppStrings.speakLanguages, 230),
    AppTableColumn(AppStrings.status, 133),
    AppTableColumn('', 90),
  ];
  static const double _avatarGap = 10;

  final List<HostRequest> requests;

  @override
  Widget build(BuildContext context) {
    final textColor = context.colorScheme.onSurface;
    final cell = AppTextStyles.bodySmall.copyWith(color: textColor);
    final strong = cell.copyWith(fontWeight: FontWeight.w700);
    final mono = AppTextStyles.mono.copyWith(color: textColor);
    const palette = AppColors.avatarPalette;

    return AppDataTable(
      columns: _columns,
      onRowTap: (index) => openHostRequest(context, requests[index]),
      rows: [
        for (final request in requests)
          () {
            final (statusLabel, status) = HostRequestLabels.status(
              request.status,
            );
            return [
              Text(DateFormatter.short(request.submittedOn), style: cell),
              Row(
                children: [
                  AppInitialsAvatar(
                    initials: request.initials,
                    color: palette[request.avatarIndex % palette.length],
                  ),
                  const SizedBox(width: _avatarGap),
                  Expanded(child: Text(request.realName, style: strong)),
                ],
              ),
              Text(request.nickName, style: cell),
              Text(request.phone, style: mono),
              Text(DateFormatter.short(request.dateOfBirth), style: cell),
              Text(request.city, style: cell),
              Text(HostProfileLabels.gender(request.gender), style: cell),
              Text(HostRequestLabels.languages(request), style: cell),
              AppStatusBadge(label: statusLabel, status: status),
              if (request.isPending)
                AppPrimaryButton(
                  label: AppStrings.review,
                  small: true,
                  onPressed: () => openHostRequest(context, request),
                )
              else
                AppSecondaryButton(
                  label: AppStrings.view,
                  small: true,
                  onPressed: () => openHostRequest(context, request),
                ),
            ];
          }(),
      ],
    );
  }
}
