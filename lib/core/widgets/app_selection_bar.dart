import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';

class AppSelectionBar extends StatelessWidget {
  const AppSelectionBar({
    super.key,
    required this.summary,
    required this.actionLabel,
    required this.onAction,
    required this.onClear,
    this.selectAllLabel,
    this.onSelectAll,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.busy = false,
  });

  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: AppUtils.spacingMd,
    vertical: AppUtils.spacingSm,
  );

  final String summary;
  final String actionLabel;
  final VoidCallback onAction;
  final VoidCallback onClear;
  final String? selectAllLabel;
  final VoidCallback? onSelectAll;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final selectAllLabel = this.selectAllLabel;
    final onSelectAll = this.onSelectAll;
    final secondaryActionLabel = this.secondaryActionLabel;
    final onSecondaryAction = this.onSecondaryAction;

    return Container(
      padding: _padding,
      decoration: const BoxDecoration(
        color: AppColors.statTileBackground,
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppUtils.spacingMd,
        runSpacing: AppUtils.spacingSm,
        children: [
          Text(
            summary,
            style: AppTextStyles.tableCell.copyWith(
              color: context.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          Wrap(
            spacing: AppUtils.spacingSm,
            runSpacing: AppUtils.spacingSm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (selectAllLabel != null && onSelectAll != null)
                AppSecondaryButton(
                  label: selectAllLabel,
                  small: true,
                  onPressed: busy ? null : onSelectAll,
                ),
              AppSecondaryButton(
                label: AppStrings.clearSelection,
                small: true,
                onPressed: busy ? null : onClear,
              ),
              if (secondaryActionLabel != null && onSecondaryAction != null)
                AppSecondaryButton(
                  label: secondaryActionLabel,
                  small: true,
                  onPressed: busy ? null : onSecondaryAction,
                ),
              AppPrimaryButton(
                label: actionLabel,
                small: true,
                onPressed: busy ? null : onAction,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
