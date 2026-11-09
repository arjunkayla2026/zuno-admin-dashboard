import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_stat_cards.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_details_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/widgets/user_history_card.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/widgets/user_profile_card.dart';

class UserDetailsContent extends StatelessWidget {
  const UserDetailsContent({super.key});

  static const double _backIconSize = 16;
  static const double _backGap = 18;
  static const double _sectionGap = 18;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(32, 24, 32, 32);
  static const EdgeInsets _mobilePadding = EdgeInsets.all(AppUtils.spacingLg);

  void _goBack(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacementNamed(AppRoutes.userManagement);
    }
  }

  @override
  Widget build(BuildContext context) {
    final muted = context.appColors.textSecondary;
    final user = context.select((UserDetailsCubit cubit) => cubit.state.user);

    return SingleChildScrollView(
      padding: AppUtils.isMobile(context) ? _mobilePadding : _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => _goBack(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chevron_left_rounded,
                    size: _backIconSize,
                    color: muted,
                  ),
                  const SizedBox(width: AppUtils.spacingXs),
                  Text(
                    AppStrings.backToUsers,
                    style: AppTextStyles.bodySmall.copyWith(color: muted),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: _backGap),
          UserProfileCard(user: user),
          const SizedBox(height: _sectionGap),
          AppStatCards(
            stats: context.select(
              (UserDetailsCubit cubit) => cubit.state.stats,
            ),
          ),
          const SizedBox(height: _sectionGap),
          UserHistoryCard(user: user),
        ],
      ),
    );
  }
}
