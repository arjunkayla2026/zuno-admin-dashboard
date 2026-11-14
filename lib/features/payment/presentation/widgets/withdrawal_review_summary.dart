import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';

class WithdrawalReviewSummary extends StatelessWidget {
  const WithdrawalReviewSummary({
    super.key,
    required this.withdrawal,
    required this.tdsPercent,
  });

  static const int _labelFlex = 2;
  static const int _valueFlex = 3;
  static const double _rowGap = 7;
  static const double _labelGap = 12;
  static const double _totalGap = 9;
  static const double _radius = 10;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(13, 13, 13, 12);

  final Withdrawal withdrawal;
  final int tdsPercent;

  Widget _row(String label, InlineSpan value, TextStyle labelStyle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          flex: _labelFlex,
          child: Text(label, style: labelStyle),
        ),
        const SizedBox(width: _labelGap),
        Flexible(
          flex: _valueFlex,
          child: Text.rich(value, textAlign: TextAlign.end),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = context.colorScheme.onSurface;
    final mutedColor = context.appColors.textSecondary;
    final label = AppTextStyles.tableFootnote.copyWith(color: mutedColor);
    const value = AppTextStyles.summaryValue;
    final styledValue = value.copyWith(color: AppColors.segmentText);
    final mono = AppTextStyles.monoSmall.copyWith(
      color: AppColors.segmentText,
      fontSize: value.fontSize,
      height: value.height,
    );
    final mutedMono = AppTextStyles.captionSmall.copyWith(
      fontFamily: AppTextStyles.monoSmall.fontFamily,
      letterSpacing: AppTextStyles.monoSmall.letterSpacing,
      color: mutedColor,
    );
    final totalLabel = AppTextStyles.bodySmall.copyWith(color: mutedColor);
    final totalValue = AppTextStyles.tableCell.copyWith(
      color: textColor,
      fontWeight: FontWeight.w700,
    );

    final rows = [
      _row(
        AppStrings.accountHolderName,
        TextSpan(text: withdrawal.accountHolderName, style: styledValue),
        label,
      ),
      _row(
        AppStrings.bank,
        TextSpan(
          children: [
            TextSpan(text: withdrawal.branchName, style: styledValue),
            TextSpan(
              text: AppStrings.ifscSuffix(withdrawal.ifscCode),
              style: mutedMono,
            ),
          ],
        ),
        label,
      ),
      _row(
        AppStrings.accountNumber,
        TextSpan(text: withdrawal.accountNumber, style: mono),
        label,
      ),
      _row(
        AppStrings.totalAmount,
        TextSpan(
          text: NumberFormatter.rupeesAmount(withdrawal.totalAmount),
          style: styledValue,
        ),
        label,
      ),
      _row(
        AppStrings.tdsLabel(tdsPercent),
        TextSpan(
          text: AppStrings.deduction(
            NumberFormatter.rupeesAmount(withdrawal.tdsAmount(tdsPercent)),
          ),
          style: styledValue,
        ),
        label,
      ),
    ];

    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: AppColors.statTileBackground,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, row) in rows.indexed) ...[
            if (index > 0) const SizedBox(height: _rowGap),
            row,
          ],
          const SizedBox(height: _totalGap),
          const Divider(color: AppColors.cardBorder),
          const SizedBox(height: _totalGap),
          _row(
            AppStrings.totalReceivableAmount,
            TextSpan(
              text: NumberFormatter.rupeesAmount(
                withdrawal.receivableAmount(tdsPercent),
              ),
              style: totalValue,
            ),
            totalLabel,
          ),
        ],
      ),
    );
  }
}
