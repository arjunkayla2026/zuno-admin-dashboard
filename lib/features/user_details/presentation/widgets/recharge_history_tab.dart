import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_search_field.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_wallet_adjustment_dialog.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_details_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_recharge_history_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/widgets/add_recharge_flow.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/widgets/recharge_history_results.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/state/user_actions_cubit.dart';

class RechargeHistoryTab extends StatelessWidget {
  const RechargeHistoryTab({super.key, required this.user});

  final AdminUser user;

  static const double _searchWidth = 340;
  static const double _searchPadding = 11;
  static const double _walletIconSize = 16;
  static const double _actionGap = 10;
  static const EdgeInsets _toolbarPadding = EdgeInsets.fromLTRB(20, 14, 20, 14);

  Future<void> _adjustWallet(BuildContext context) async {
    final details = context.read<UserDetailsCubit>();
    final actions = context.read<UserActionsCubit>();
    final history = context.read<UserRechargeHistoryCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final adjustment = await showWalletAdjustmentDialog(
      context: context,
      walletBalance: details.state.walletBalance,
    );
    if (adjustment == null) return;

    final error = await actions.adjustWallet(
      details.state.user,
      type: adjustment.type,
      amount: adjustment.amount,
      description: adjustment.description,
    );
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    } else if (!details.isClosed) {
      details.adjustWallet(adjustment);
      await history.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: _toolbarPadding,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppUtils.spacingMd,
            runSpacing: AppUtils.spacingSm,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _searchWidth),
                child: AppSearchField(
                  hint: AppStrings.searchRechargesHint,
                  verticalPadding: _searchPadding,
                  onChanged: context.read<UserRechargeHistoryCubit>().search,
                ),
              ),
              Wrap(
                spacing: _actionGap,
                runSpacing: AppUtils.spacingSm,
                children: [
                  AppSecondaryButton(
                    label: AppStrings.creditDebitWallet,
                    onPressed: () => _adjustWallet(context),
                    leading: SvgPicture.asset(
                      AppImages.paymentIcon,
                      width: _walletIconSize,
                      height: _walletIconSize,
                      colorFilter: ColorFilter.mode(
                        context.colorScheme.onSurface,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  AppPrimaryButton(
                    label: AppStrings.addRecharge,
                    icon: Icons.add_rounded,
                    compact: true,
                    onPressed: () => startAddRecharge(context, user),
                  ),
                ],
              ),
            ],
          ),
        ),
        const RechargeHistoryResults(),
      ],
    );
  }
}
