import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_detail_grid.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_initials_avatar.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_side_sheet.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_badge.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/models/recharge_transaction.dart';
import 'package:zuno_admin_dashboard/features/recharge/presentation/widgets/recharge_labels.dart';
import 'package:zuno_admin_dashboard/features/recharge/presentation/widgets/recharge_summary_panel.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/state/user_details_arguments.dart';

Future<void> showRechargeDetails(
  BuildContext context,
  RechargeTransaction transaction,
) {
  return showAppSideSheet<void>(
    context: context,
    builder: (_) => RechargeDetailsSheet(transaction: transaction),
  );
}

class RechargeDetailsSheet extends StatelessWidget {
  const RechargeDetailsSheet({super.key, required this.transaction});

  static const double _avatarSize = 56;
  static const double _avatarGap = 14;
  static const double _sectionGap = 22;

  final RechargeTransaction transaction;

  void _viewUser(BuildContext context, AdminUser user) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.pushNamed(
      AppRoutes.userDetails,
      arguments: UserDetailsArguments(user: user),
    );
  }

  Widget _header(BuildContext context) {
    const palette = AppColors.avatarPalette;
    final (statusLabel, status) = RechargeLabels.status(transaction.status);

    return Row(
      children: [
        AppInitialsAvatar(
          initials: transaction.initials,
          color: palette[transaction.avatarIndex % palette.length],
          size: _avatarSize,
        ),
        const SizedBox(width: _avatarGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.userName,
                style: AppTextStyles.titleMedium.copyWith(
                  color: context.colorScheme.onSurface,
                ),
              ),
              Text(
                transaction.userId,
                style: AppTextStyles.monoSmall.copyWith(
                  color: context.appColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        AppStatusBadge(label: statusLabel, status: status),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = transaction.user;
    final (statusLabel, status) = RechargeLabels.status(transaction.status);

    return AppSideSheet(
      title: AppStrings.rechargeDetails,
      subtitle: RechargeLabels.source(transaction),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(context),
          const SizedBox(height: _sectionGap),
          RechargeSummaryPanel(transaction: transaction),
          const SizedBox(height: _sectionGap),
          AppDetailGrid(
            items: [
              AppDetailItem(
                AppStrings.date,
                value: RechargeLabels.date(transaction),
              ),
              AppDetailItem(
                AppStrings.time,
                value: RechargeLabels.time(transaction),
              ),
              AppDetailItem(AppStrings.name, value: transaction.userName),
              AppDetailItem(
                AppStrings.phoneNumber,
                value: transaction.phone,
                mono: true,
              ),
              AppDetailItem(
                AppStrings.rechargeAmount,
                value: RechargeLabels.amountFor(
                  transaction,
                  RechargeKind.recharge,
                ),
              ),
              AppDetailItem(
                AppStrings.adminCreditAmount,
                value: RechargeLabels.amountFor(
                  transaction,
                  RechargeKind.credit,
                ),
              ),
              AppDetailItem(
                AppStrings.adminDebitAmount,
                value: RechargeLabels.amountFor(
                  transaction,
                  RechargeKind.debit,
                ),
              ),
              AppDetailItem(
                AppStrings.receivedCoins,
                value: RechargeLabels.coins(transaction),
              ),
              AppDetailItem(
                AppStrings.paymentId,
                value: transaction.paymentId ?? AppStrings.emptyValue,
                mono: true,
              ),
              AppDetailItem(
                AppStrings.orderId,
                value: transaction.displayOrderId,
                mono: true,
              ),
              AppDetailItem(
                AppStrings.paymentGateway,
                value: RechargeLabels.gateway(transaction.gateway),
              ),
              AppDetailItem(
                AppStrings.status,
                child: AppStatusBadge(label: statusLabel, status: status),
              ),
            ],
          ),
        ],
      ),
      footer: Wrap(
        spacing: AppUtils.spacingSm,
        runSpacing: AppUtils.spacingSm,
        children: [
          AppSecondaryButton(
            label: AppStrings.viewUser,
            onPressed: user == null ? null : () => _viewUser(context, user),
          ),
          AppPrimaryButton(
            label: AppStrings.close,
            compact: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
