import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/enums/app_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_badge.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/mock_withdrawal_summary.dart';

/// Each mock host's stored withdrawn total against its success records.
class MockHostWithdrawnTotals extends StatelessWidget {
  const MockHostWithdrawnTotals({super.key, required this.hosts});

  final List<MockHostTotals> hosts;

  @override
  Widget build(BuildContext context) {
    final onSurface = context.colorScheme.onSurface;
    final muted = context.appColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStrings.mockHostWithdrawnTotals,
          style: AppTextStyles.labelMedium.copyWith(color: onSurface),
        ),
        const SizedBox(height: AppUtils.spacingSm),
        for (final (index, host) in hosts.indexed) ...[
          if (index > 0) const Divider(color: AppColors.cardBorder),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppUtils.spacingSm),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppUtils.spacingLg,
              runSpacing: AppUtils.spacingSm,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: host.hostName,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const TextSpan(text: '  '),
                      TextSpan(
                        text: host.hostUserId,
                        style: AppTextStyles.identifierSmall.copyWith(
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  AppStrings.mockWithdrawnBreakdown(
                    NumberFormatter.rupeesAmount(host.recordedWithdrawn),
                    NumberFormatter.rupeesAmount(host.successRecordsTotal),
                  ),
                  style: AppTextStyles.bodySmall.copyWith(color: onSurface),
                ),
                AppStatusBadge(
                  label: host.matches
                      ? AppStrings.withdrawnMatches
                      : AppStrings.withdrawnMismatch,
                  status: host.matches ? AppStatus.active : AppStatus.error,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
