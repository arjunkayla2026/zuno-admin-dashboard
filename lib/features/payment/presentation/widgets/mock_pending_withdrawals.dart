import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_avatar_name_cell.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/payment_cubit.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/payment_state.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_flow.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_labels.dart';

class MockPendingWithdrawals extends StatelessWidget {
  const MockPendingWithdrawals({super.key, required this.withdrawals});

  static const double _infoWidth = 260;

  final List<Withdrawal> withdrawals;

  @override
  Widget build(BuildContext context) {
    final muted = AppTextStyles.bodySmall.copyWith(
      color: context.appColors.textSecondary,
    );
    final title = AppTextStyles.labelMedium.copyWith(
      color: context.colorScheme.onSurface,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AppStrings.mockPendingWithdrawals, style: title),
        const SizedBox(height: AppUtils.spacingSm),
        if (withdrawals.isEmpty)
          Text(AppStrings.noMockPendingWithdrawals, style: muted)
        else
          BlocSelector<PaymentCubit, PaymentState, bool>(
            selector: (state) => state.batchRunning,
            builder: (context, busy) => Column(
              children: [
                for (final (index, withdrawal) in withdrawals.indexed) ...[
                  if (index > 0) const Divider(color: AppColors.cardBorder),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppUtils.spacingSm,
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: AppUtils.spacingLg,
                      runSpacing: AppUtils.spacingSm,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: _infoWidth,
                          ),
                          child: AppAvatarNameCell(
                            initials: withdrawal.initials,
                            avatarIndex: withdrawal.avatarIndex,
                            name: withdrawal.hostName,
                          ),
                        ),
                        Text(
                          AppStrings.dotSeparated(
                            withdrawal.withdrawId,
                            WithdrawalLabels.period(withdrawal),
                          ),
                          style: AppTextStyles.monoSmall.copyWith(
                            color: context.appColors.textSecondary,
                          ),
                        ),
                        Text(
                          NumberFormatter.rupeesAmount(withdrawal.totalAmount),
                          style: title,
                        ),
                        Wrap(
                          spacing: AppUtils.spacingSm,
                          runSpacing: AppUtils.spacingSm,
                          children: [
                            AppSecondaryButton(
                              label: AppStrings.reject,
                              small: true,
                              destructive: true,
                              onPressed: busy
                                  ? null
                                  : () => rejectWithdrawal(context, withdrawal),
                            ),
                            AppPrimaryButton(
                              label: AppStrings.markAsSuccess,
                              small: true,
                              positive: true,
                              onPressed: busy
                                  ? null
                                  : () => markWithdrawalsPaid(context, [
                                      withdrawal,
                                    ]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
