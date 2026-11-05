import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/widgets/date_range_controls.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppUtils.spacingLg,
      runSpacing: AppUtils.spacingMd,
      children: [
        Text(
          AppStrings.dashboard,
          style: AppTextStyles.headlineSmall.copyWith(
            color: context.colorScheme.onSurface,
          ),
        ),
        const DateRangeControls(),
      ],
    );
  }
}
