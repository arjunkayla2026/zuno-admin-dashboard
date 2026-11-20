import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/call_pricing_cubit.dart';

/// The configured default per-minute rates from `settings/app.setHostPrice`
/// (surge not included), read through [CallPricingCubit], as compact chips.
class DefaultCallRateCards extends StatelessWidget {
  const DefaultCallRateCards({super.key});

  static const EdgeInsets _padding = EdgeInsets.fromLTRB(20, 12, 20, 0);
  static const EdgeInsets _chipPadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 5,
  );

  @override
  Widget build(BuildContext context) {
    final pricing = context.select(
      (CallPricingCubit cubit) => cubit.state.pricing,
    );
    final muted = AppTextStyles.tableFootnote.copyWith(
      color: context.appColors.textSecondary,
    );
    final strong = AppTextStyles.tableFootnote.copyWith(
      color: context.colorScheme.onSurface,
      fontWeight: FontWeight.w700,
    );

    String rate(double? amount) => amount == null
        ? AppStrings.emptyValue
        : AppStrings.perMinute(NumberFormatter.rupeesAmount(amount));

    Widget chip(String label, double? amount) => Container(
      padding: _chipPadding,
      decoration: BoxDecoration(
        color: AppColors.statTileBackground,
        borderRadius: AppUtils.radiusSmall,
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$label  ', style: muted),
            TextSpan(text: rate(amount), style: strong),
          ],
        ),
      ),
    );

    return Padding(
      padding: _padding,
      child: Wrap(
        spacing: AppUtils.spacingSm,
        runSpacing: AppUtils.spacingXs,
        children: [
          chip(
            AppStrings.defaultHostAudioCallRevenue,
            pricing?.audio.hostAmount,
          ),
          chip(
            AppStrings.defaultHostVideoCallRevenue,
            pricing?.video.hostAmount,
          ),
          chip(
            AppStrings.defaultAdminAudioCallRevenue,
            pricing?.audio.adminAmount,
          ),
          chip(
            AppStrings.defaultAdminVideoCallRevenue,
            pricing?.video.adminAmount,
          ),
        ],
      ),
    );
  }
}
