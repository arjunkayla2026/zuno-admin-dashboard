import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/payout_batch_result.dart';

class PayoutBatchFailures extends StatelessWidget {
  const PayoutBatchFailures({super.key, required this.failures});

  static const double _maxHeight = 180;
  static const double _radius = 10;
  static const EdgeInsets _padding = EdgeInsets.all(AppUtils.spacingMd);

  final List<PayoutFailure> failures;

  @override
  Widget build(BuildContext context) {
    final textColor = context.colorScheme.onSurface;
    final mutedColor = context.appColors.textSecondary;

    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: AppColors.statTileBackground,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.payoutBatchFailuresTitle,
            style: AppTextStyles.tableCell.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppUtils.spacingSm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: _maxHeight),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final failure in failures)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppUtils.spacingSm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.payoutFailureLine(
                              failure.withdrawal.hostName,
                              failure.withdrawal.withdrawId,
                            ),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            failure.message,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: mutedColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
