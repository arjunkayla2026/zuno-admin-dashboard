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
import 'package:zuno_admin_dashboard/features/approval/data/models/payout_request.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/payout_request_flow.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/payout_request_labels.dart';

class PayoutRequestsTable extends StatelessWidget {
  const PayoutRequestsTable({super.key, required this.payouts});

  static const List<AppTableColumn> _columns = [
    AppTableColumn(AppStrings.date, 138),
    AppTableColumn(AppStrings.hostName, 157),
    AppTableColumn(AppStrings.hostId, 104),
    AppTableColumn(AppStrings.accountHolderName, 194),
    AppTableColumn(AppStrings.branchName, 253),
    AppTableColumn(AppStrings.accountNumber, 158),
    AppTableColumn(AppStrings.ifscCode, 144),
    AppTableColumn(AppStrings.status, 155),
    AppTableColumn('', 90),
  ];
  static const double _avatarGap = 10;

  final List<PayoutRequest> payouts;

  @override
  Widget build(BuildContext context) {
    final textColor = context.colorScheme.onSurface;
    final cell = AppTextStyles.bodySmall.copyWith(color: textColor);
    final strong = cell.copyWith(fontWeight: FontWeight.w700);
    final mono = AppTextStyles.mono.copyWith(color: textColor);
    const palette = AppColors.avatarPalette;

    return AppDataTable(
      columns: _columns,
      onRowTap: (index) => openPayoutRequest(context, payouts[index]),
      rows: [
        for (final payout in payouts)
          () {
            final (statusLabel, status) = PayoutRequestLabels.status(
              payout.status,
            );
            return [
              Text(DateFormatter.short(payout.submittedOn), style: cell),
              Row(
                children: [
                  AppInitialsAvatar(
                    initials: payout.initials,
                    color: palette[payout.avatarIndex % palette.length],
                  ),
                  const SizedBox(width: _avatarGap),
                  Expanded(child: Text(payout.hostName, style: strong)),
                ],
              ),
              Text(payout.hostId, style: mono),
              Text(payout.accountHolderName, style: cell),
              Text(payout.branchName, style: cell),
              Text(payout.accountNumber, style: cell),
              Text(payout.ifscCode, style: mono),
              AppStatusBadge(label: statusLabel, status: status),
              if (payout.isPending)
                AppPrimaryButton(
                  label: AppStrings.review,
                  small: true,
                  onPressed: () => openPayoutRequest(context, payout),
                )
              else
                AppSecondaryButton(
                  label: AppStrings.view,
                  small: true,
                  onPressed: () => openPayoutRequest(context, payout),
                ),
            ];
          }(),
      ],
    );
  }
}
