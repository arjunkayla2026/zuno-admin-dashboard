import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_details_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_details_state.dart';

class HistoryTabs extends StatelessWidget {
  const HistoryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserDetailsCubit, UserDetailsState>(
      builder: (context, state) {
        final cubit = context.read<UserDetailsCubit>();

        return Wrap(
          children: [
            _HistoryTab(
              label: AppStrings.callHistory,
              count: state.calls.length,
              selected: state.tab == UserDetailsTab.calls,
              onTap: () => cubit.selectTab(UserDetailsTab.calls),
            ),
            _HistoryTab(
              label: AppStrings.rechargeHistory,
              count: state.recharges.length,
              selected: state.tab == UserDetailsTab.recharges,
              onTap: () => cubit.selectTab(UserDetailsTab.recharges),
            ),
          ],
        );
      },
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  static const double _height = 44;
  static const double _sidePadding = 17;
  static const double _countGap = 8;
  static const double _underline = 2;
  static const double _countRadius = 5;
  static const EdgeInsets _countPadding = EdgeInsets.symmetric(
    horizontal: 6,
    vertical: 1,
  );

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      child: Container(
        height: _height,
        padding: const EdgeInsets.symmetric(horizontal: _sidePadding),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? AppColors.primary : AppColors.transparent,
              width: _underline,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: selected
                    ? context.colorScheme.onSurface
                    : colors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: _countGap),
            Container(
              padding: _countPadding,
              decoration: BoxDecoration(
                color: colors.inactiveBadge,
                borderRadius: BorderRadius.circular(_countRadius),
              ),
              child: Text(
                '$count',
                style: AppTextStyles.captionSmall.copyWith(
                  color: colors.inactiveText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
