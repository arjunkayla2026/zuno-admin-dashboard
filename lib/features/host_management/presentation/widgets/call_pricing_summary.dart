import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/host_management_cubit.dart';

class CallPricingSummary extends StatelessWidget {
  const CallPricingSummary({super.key});

  static const double _iconSize = 13;
  static const double _itemGap = 18;
  static const double _iconGap = 3;

  @override
  Widget build(BuildContext context) {
    final pricing = context.select(
      (HostManagementCubit cubit) => cubit.state.pricing,
    );
    final color = context.colorScheme.onSurface;
    final style = AppTextStyles.tableFootnote.copyWith(
      color: color,
      fontWeight: FontWeight.w500,
    );

    Widget item(String label, [IconData? icon]) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: _iconSize, color: color),
          const SizedBox(width: _iconGap),
        ],
        Text(label, style: style),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppUtils.spacingSm),
      child: Wrap(
        spacing: _itemGap,
        runSpacing: AppUtils.spacingXs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          item(
            AppStrings.audioRateSummary(pricing.audioPerSecond),
            Icons.mic_none_rounded,
          ),
          item(
            AppStrings.videoRateSummary(pricing.videoPerSecond),
            Icons.videocam_outlined,
          ),
          item(AppStrings.messageRateSummary(pricing.perMessage)),
        ],
      ),
    );
  }
}
