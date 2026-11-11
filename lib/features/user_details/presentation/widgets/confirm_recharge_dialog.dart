import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_dialog_surface.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/features/user_details/data/models/recharge_package.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/add_recharge_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/widgets/recharge_dialog_header.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';

class ConfirmRechargeDialog extends StatefulWidget {
  const ConfirmRechargeDialog({
    super.key,
    required this.user,
    required this.package,
  });

  final AdminUser user;
  final RechargePackage package;

  @override
  State<ConfirmRechargeDialog> createState() => _ConfirmRechargeDialogState();
}

class _ConfirmRechargeDialogState extends State<ConfirmRechargeDialog> {
  static const double _messageTopGap = 14;
  static const double _summaryGap = 16;
  static const double _actionsGap = 24;
  static const double _actionSpacing = 10;
  static const double _summaryRowHeight = 30;
  static const double _summaryVerticalPadding = 14;
  static const EdgeInsets _padding = EdgeInsets.all(AppUtils.spacingXl);
  static const EdgeInsets _summaryPadding = EdgeInsets.symmetric(
    horizontal: AppUtils.spacingLg,
    vertical: _summaryVerticalPadding,
  );

  late final String _requestId = context
      .read<AddRechargeCubit>()
      .newRequestId();

  Future<void> _submit() async {
    final result = await context.read<AddRechargeCubit>().submit(
      userId: widget.user.id,
      package: widget.package,
      requestId: _requestId,
    );
    if (result != null && mounted) Navigator.of(context).pop(result);
  }

  Widget _summaryRow(BuildContext context, String label, String value) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: _summaryRowHeight),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.labelSmall.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final package = widget.package;
    final state = context.watch<AddRechargeCubit>().state;
    final isSubmitting = state.isSubmitting;
    final error = state.submitError;

    return PopScope(
      canPop: !isSubmitting,
      child: AppDialogSurface(
        padding: _padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const RechargeDialogHeader(title: AppStrings.confirmRecharge),
            const SizedBox(height: _messageTopGap),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: AppStrings.confirmRechargeLead),
                  TextSpan(
                    text: widget.user.name,
                    style: TextStyle(
                      color: context.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: AppStrings.confirmRechargeTail),
                ],
              ),
              style: AppTextStyles.tableCell.copyWith(
                color: AppColors.dialogMessage,
              ),
            ),
            const SizedBox(height: _summaryGap),
            Container(
              padding: _summaryPadding,
              decoration: BoxDecoration(
                color: AppColors.statTileBackground,
                borderRadius: AppUtils.radiusSmall,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _summaryRow(context, AppStrings.package, package.priceLabel),
                  _summaryRow(
                    context,
                    AppStrings.coinsLabel,
                    NumberFormatter.grouped(package.coins),
                  ),
                  _summaryRow(
                    context,
                    AppStrings.offer,
                    package.hasBonus
                        ? AppStrings.bonusLabel(
                            NumberFormatter.grouped(package.bonus),
                          )
                        : AppStrings.emptyValue,
                  ),
                  const Divider(color: AppColors.cardBorder),
                  _summaryRow(
                    context,
                    AppStrings.coinsAdded,
                    NumberFormatter.grouped(package.totalCoins),
                  ),
                ],
              ),
            ),
            if (isSubmitting) ...[
              const SizedBox(height: _summaryGap),
              const LinearProgressIndicator(),
            ],
            if (error != null) ...[
              const SizedBox(height: _summaryGap),
              Text(
                error,
                style: AppTextStyles.tableCell.copyWith(
                  color: context.appColors.errorText,
                ),
              ),
            ],
            const SizedBox(height: _actionsGap),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: _actionSpacing,
              runSpacing: AppUtils.spacingSm,
              children: [
                AppSecondaryButton(
                  label: AppStrings.cancel,
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(context).pop(),
                ),
                AppPrimaryButton(
                  label: AppStrings.addRechargeAction,
                  compact: true,
                  onPressed: isSubmitting ? null : _submit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
