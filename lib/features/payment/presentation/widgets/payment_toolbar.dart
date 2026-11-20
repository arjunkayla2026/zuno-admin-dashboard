import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zuno_admin_dashboard/core/enums/date_range_filter.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_date_filter_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_refresh_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_search_field.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/mock_withdrawals_cubit.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/payment_cubit.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/payment_state.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_flow.dart';

class PaymentToolbar extends StatelessWidget {
  const PaymentToolbar({super.key});

  static const double _searchWidth = 340;
  static const double _searchPadding = 11;
  static const double _iconSize = 16;
  static const EdgeInsets _padding = EdgeInsets.all(12);

  static String _successDateLabel(DateRangeFilter filter) => switch (filter) {
    DateRangeFilter.last7Days => AppStrings.lastWeek,
    _ => AppDateFilterButton.defaultLabel(filter),
  };

  Widget _downloadIcon(BuildContext context) => SvgPicture.asset(
    AppImages.downloadIcon,
    width: _iconSize,
    height: _iconSize,
    colorFilter: ColorFilter.mode(
      context.colorScheme.onSurface,
      BlendMode.srcIn,
    ),
  );

  List<Widget> _exportButtons(
    BuildContext context,
    bool exporting,
    bool canExportWithdrawals,
  ) {
    final withdrawalSheet = AppSecondaryButton(
      label: AppStrings.exportWithdrawalSheet,
      leading: _downloadIcon(context),
      onPressed: exporting || !canExportWithdrawals
          ? null
          : () => exportWithdrawals(context),
    );
    return [
      AppSecondaryButton(
        label: AppStrings.exportBeneficiarySheet,
        leading: _downloadIcon(context),
        onPressed: exporting ? null : () => exportBeneficiaries(context),
      ),
      if (canExportWithdrawals)
        withdrawalSheet
      else
        Tooltip(
          message: AppStrings.exportBeneficiarySheetFirst,
          child: withdrawalSheet,
        ),
    ];
  }

  Future<void> _refresh(BuildContext context) async {
    final mock = context.read<MockWithdrawalsCubit>();
    await Future.wait([
      context.read<PaymentCubit>().refresh(),
      if (mock.isAvailable) mock.load(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PaymentCubit>();
    final (tab, exporting, selectedCount, busy) = context.select(
      (PaymentCubit cubit) => (
        cubit.state.tab,
        cubit.state.exporting,
        cubit.state.selected.length,
        cubit.state.batchRunning || cubit.state.selectingAll,
      ),
    );
    final (dateFilter, customRange) = context.select(
      (PaymentCubit cubit) =>
          (cubit.state.successDateFilter, cubit.state.successCustomRange),
    );
    final canExportWithdrawals = context.select(
      (PaymentCubit cubit) => cubit.state.canExportWithdrawals,
    );
    final isPending = tab == PaymentTab.pending;
    final hasSelection = selectedCount > 0;

    return Padding(
      padding: _padding,
      child: LayoutBuilder(
        builder: (context, constraints) => Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppUtils.spacingMd,
          runSpacing: AppUtils.spacingSm,
          children: [
            Wrap(
              spacing: AppUtils.spacingSm,
              runSpacing: AppUtils.spacingSm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: constraints.maxWidth < _searchWidth
                      ? constraints.maxWidth
                      : _searchWidth,
                  child: AppSearchField(
                    hint: AppStrings.searchWithdrawalsHint,
                    verticalPadding: _searchPadding,
                    onChanged: cubit.search,
                  ),
                ),
                if (tab == PaymentTab.success)
                  AppDateFilterButton(
                    value: dateFilter,
                    today: DateUtils.dateOnly(DateTime.now()),
                    customRange: customRange,
                    options: PaymentState.successDateOptions,
                    labelOf: _successDateLabel,
                    onFilterSelected: cubit.selectSuccessDateFilter,
                    onCustomRangeSelected: cubit.selectSuccessCustomRange,
                  ),
                AppRefreshButton(
                  onRefresh: busy || exporting ? null : () => _refresh(context),
                ),
              ],
            ),
            if (isPending)
              Wrap(
                spacing: AppUtils.spacingSm,
                runSpacing: AppUtils.spacingSm,
                children: [
                  ..._exportButtons(context, exporting, canExportWithdrawals),
                  if (hasSelection)
                    AppPrimaryButton(
                      label: AppStrings.withSelectedCount(
                        AppStrings.markAsSuccess,
                        selectedCount,
                      ),
                      compact: true,
                      positive: true,
                      onPressed: busy || exporting
                          ? null
                          : () => markSelectedPaid(context),
                    ),
                ],
              ),
            if (tab == PaymentTab.withdrawalList)
              Wrap(
                spacing: AppUtils.spacingSm,
                runSpacing: AppUtils.spacingSm,
                children: [
                  ..._exportButtons(context, exporting, canExportWithdrawals),
                  if (hasSelection)
                    AppPrimaryButton(
                      label: AppStrings.withSelectedCount(
                        AppStrings.moveToPending,
                        selectedCount,
                      ),
                      compact: true,
                      onPressed: busy || exporting
                          ? null
                          : () => moveSelectedToPending(context),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
