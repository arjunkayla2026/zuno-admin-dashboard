import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/features/user_details/data/models/recharge_package.dart';

class RechargePackageTile extends StatelessWidget {
  const RechargePackageTile({
    super.key,
    required this.package,
    required this.selected,
    required this.onTap,
  });

  static const double _minHeight = 42;
  static const double _sidePadding = 14;
  static const double _gap = 8;

  final RechargePackage package;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTheme.radiusField);
    final coins = AppStrings.coinsWithBonus(
      NumberFormatter.grouped(package.coins),
      package.hasBonus ? NumberFormatter.grouped(package.bonus) : null,
    );

    return Material(
      color: selected ? AppColors.selectedOption : AppColors.surface,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          constraints: const BoxConstraints(minHeight: _minHeight),
          padding: const EdgeInsets.symmetric(horizontal: _sidePadding),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: selected ? null : Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  package.priceLabel,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: selected ? AppColors.white : AppColors.segmentText,
                  ),
                ),
              ),
              const SizedBox(width: _gap),
              Expanded(
                child: Text(
                  coins,
                  textAlign: TextAlign.end,
                  style: AppTextStyles.tableFootnote.copyWith(
                    color: selected ? AppColors.white : AppColors.segmentText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
