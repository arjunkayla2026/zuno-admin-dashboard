import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/state/dashboard_cubit.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/state/dashboard_state.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/widgets/date_range_dropdown.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/widgets/date_range_field.dart';

class DateRangeControls extends StatelessWidget {
  const DateRangeControls({super.key});

  static const double _dropdownGap = 14;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final cubit = context.read<DashboardCubit>();

        return Wrap(
          spacing: _dropdownGap,
          runSpacing: AppUtils.spacingSm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (state.isCustomRange)
              Wrap(
                spacing: AppUtils.spacingMd,
                runSpacing: AppUtils.spacingSm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  DateRangeField(
                    date: state.customStart,
                    lastDate: state.customEnd,
                    onChanged: cubit.setCustomStart,
                  ),
                  Text(
                    AppStrings.dateRangeSeparator,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: context.appColors.textSecondary,
                    ),
                  ),
                  DateRangeField(
                    date: state.customEnd,
                    firstDate: state.customStart,
                    onChanged: cubit.setCustomEnd,
                  ),
                ],
              ),
            DateRangeDropdown(
              value: state.rangeType,
              onChanged: cubit.selectRangeType,
            ),
          ],
        );
      },
    );
  }
}
