import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_dialog_surface.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_search_field.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/call_pricing_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/host_management_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/widgets/call_pricing_dialog.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/widgets/call_pricing_summary.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/widgets/host_filter_dropdown.dart';

class HostToolbar extends StatelessWidget {
  const HostToolbar({super.key});

  static const double _searchWidth = 478;
  static const double _buttonIconSize = 16;

  Future<void> _openPricing(BuildContext context) async {
    final cubit = context.read<CallPricingCubit>();
    final messenger = ScaffoldMessenger.of(context);
    if (cubit.state.pricing == null) await cubit.load();
    final pricing = cubit.state.pricing;
    if (pricing == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            cubit.state.errorMessage ?? AppStrings.recordsLoadFailed,
          ),
        ),
      );
      return;
    }
    if (!context.mounted) return;
    await showAppDialog<void>(
      context: context,
      builder: (_) => CallPricingDialog(pricing: pricing, onSave: cubit.save),
    );
  }

  Widget _icon(BuildContext context, String asset) => SvgPicture.asset(
    asset,
    width: _buttonIconSize,
    height: _buttonIconSize,
    colorFilter: ColorFilter.mode(
      context.colorScheme.onSurface,
      BlendMode.srcIn,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final showsPricing = context.select(
      (HostManagementCubit cubit) => cubit.state.showsPricing,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _searchWidth),
                child: AppSearchField(
                  hint: AppStrings.searchHostsHint,
                  onChanged: context.read<HostManagementCubit>().search,
                ),
              ),
            ),
            const SizedBox(width: AppUtils.spacingXs),
            const HostFilterDropdown(),
          ],
        ),
        const SizedBox(height: AppUtils.spacingSm),
        Wrap(
          spacing: AppUtils.spacingSm,
          runSpacing: AppUtils.spacingSm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            AppSecondaryButton(
              label: AppStrings.setCallMessagePrice,
              leading: _icon(context, AppImages.dbIcon),
              onPressed: () => _openPricing(context),
            ),
            AppSecondaryButton(
              label: AppStrings.surgeChargeSessions,
              leading: _icon(context, AppImages.surgeChargeIcon),
              onPressed: () =>
                  Navigator.of(context)
                      .pushNamed(AppRoutes.surgeChargeSessions),
            ),
            if (showsPricing) const CallPricingSummary(),
          ],
        ),
      ],
    );
  }
}
