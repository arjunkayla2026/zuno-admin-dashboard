import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_underline_tabs.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_wallet_adjustment_dialog.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/state/call_history_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/state/host_details_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/state/host_details_state.dart';

class HostHistoryTabBar extends StatelessWidget {
  const HostHistoryTabBar({super.key});

  static const double _walletIconSize = 16;
  static const EdgeInsets _buttonPadding = EdgeInsets.symmetric(
    horizontal: AppUtils.spacingMd,
    vertical: AppUtils.spacingXs,
  );

  Future<void> _adjustWallet(BuildContext context) async {
    final cubit = context.read<HostDetailsCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final adjustment = await showWalletAdjustmentDialog(
      context: context,
      walletBalance: cubit.state.pendingTotal.floor(),
    );
    if (adjustment == null) return;
    final error = await cubit.adjustWallet(adjustment);
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HostDetailsCubit>().state;
    final totalCalls = context.select(
      (CallHistoryCubit cubit) => cubit.state.totalCount,
    );

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        AppUnderlineTabs<HostDetailsTab>(
          tabs: const {
            HostDetailsTab.calls: AppStrings.callHistory,
            HostDetailsTab.withdrawals: AppStrings.withdrawalHistory,
            HostDetailsTab.wallet: AppStrings.walletHistory,
          },
          counts: {
            HostDetailsTab.calls: ?totalCalls,
            HostDetailsTab.withdrawals: ?state.withdrawalCount,
          },
          value: state.tab,
          onChanged: context.read<HostDetailsCubit>().selectTab,
        ),
        Padding(
          padding: _buttonPadding,
          child: AppSecondaryButton(
            label: AppStrings.creditDebitWallet,
            onPressed: state.adjusting ? null : () => _adjustWallet(context),
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
        ),
      ],
    );
  }
}
