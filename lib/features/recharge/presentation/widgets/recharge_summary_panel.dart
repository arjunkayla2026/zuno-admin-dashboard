import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/models/recharge_transaction.dart';
import 'package:zuno_admin_dashboard/features/recharge/presentation/widgets/recharge_labels.dart';

class RechargeSummaryPanel extends StatelessWidget {
  const RechargeSummaryPanel({super.key, required this.transaction});

  static const double _valueGap = 2;
  static const double _columnGap = 22;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(16, 16, 16, 20);

  final RechargeTransaction transaction;

  Widget _figure(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.captionSmall.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
        const SizedBox(height: _valueGap),
        Text(
          value,
          style: AppTextStyles.headlineSmall.copyWith(
            color: context.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: AppColors.statTileBackground,
        borderRadius: AppUtils.radiusSmall,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Wrap(
        spacing: _columnGap,
        runSpacing: AppUtils.spacingSm,
        children: [
          _figure(
            context,
            RechargeLabels.amountLabel(transaction.kind),
            NumberFormatter.rupees(transaction.amount),
          ),
          _figure(
            context,
            AppStrings.receivedCoins,
            RechargeLabels.coins(transaction),
          ),
        ],
      ),
    );
  }
}
