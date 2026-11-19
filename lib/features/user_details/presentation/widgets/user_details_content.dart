import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_back_link.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_stat_cards.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_details_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/widgets/user_details_refresh_button.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/widgets/user_history_card.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/widgets/user_profile_card.dart';

class UserDetailsContent extends StatelessWidget {
  const UserDetailsContent({super.key});

  static const double _backGap = 18;
  static const double _sectionGap = 18;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(32, 24, 32, 32);
  static const EdgeInsets _mobilePadding = EdgeInsets.all(AppUtils.spacingLg);

  @override
  Widget build(BuildContext context) {
    final user = context.select((UserDetailsCubit cubit) => cubit.state.user);

    return SingleChildScrollView(
      padding: AppUtils.isMobile(context) ? _mobilePadding : _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppBackLink(
            label: AppStrings.backToUsers,
            fallbackRoute: AppRoutes.userManagement,
            trailing: UserDetailsRefreshButton(),
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
