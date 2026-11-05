import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_initials_avatar.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/state/user_details_arguments.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/state/user_management_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/widgets/user_action_button.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/widgets/user_table_columns.dart';

class UserTableRow extends StatelessWidget {
  const UserTableRow({super.key, required this.user});

  static const double _height = 55;
  static const double _avatarGap = 10;
  static const double _noActionsInset = 17;
  static const double _nameLineHeight = 1.25;
  static const double _statusLineHeight = 1.1;

  final AdminUser user;

  String? get _statusLabel => switch (user.status) {
    UserStatus.active => null,
    UserStatus.newUser => AppStrings.newUser,
    UserStatus.blocked => AppStrings.blocked,
    UserStatus.deletedByAdmin => AppStrings.deletedByAdmin,
    UserStatus.deletedByUser => AppStrings.deletedByUser,
  };

  @override
  Widget build(BuildContext context) {
    final textColor = context.colorScheme.onSurface;
    final mutedColor = context.appColors.textSecondary;
    final cell = AppTextStyles.tableCell.copyWith(color: textColor);
    final mono = AppTextStyles.mono.copyWith(color: textColor);
    final avatarColors = AppColors.avatarPalette;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(
          AppRoutes.userDetails,
          arguments: UserDetailsArguments(
            user: user,
            onUserChanged: context.read<UserManagementCubit>().replaceUser,
          ),
        ),
        child: Container(
          constraints: const BoxConstraints(minHeight: _height),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
          ),
          child: UserTableColumns(
            createdDate: Text(user.createdDate, style: cell),
            name: Row(
              children: [
                AppInitialsAvatar(
                  initials: user.initials,
                  color: avatarColors[user.avatarIndex % avatarColors.length],
                ),
                const SizedBox(width: _avatarGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          height: _nameLineHeight,
                        ),
                      ),
                      if (_statusLabel case final status?)
                        Text(
                          status,
                          style: AppTextStyles.captionSmall.copyWith(
                            color: mutedColor,
                            height: _statusLineHeight,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            userId: Text(user.userId, style: mono),
            phone: Text(user.phone, style: mono),
            recharges: Text('${user.recharges}', style: cell),
            wallet: Text.rich(
              TextSpan(
                style: cell.copyWith(color: mutedColor),
                children: [
                  TextSpan(
                    text: user.walletBalance,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: ' ${AppStrings.coins}'),
                ],
              ),
            ),
            action: user.hasActions
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: UserActionButton(user: user),
                  )
                : Padding(
                    padding: const EdgeInsets.only(left: _noActionsInset),
                    child: Text(
                      AppStrings.noActions,
                      style: AppTextStyles.tableFootnote.copyWith(
                        color: AppColors.tableMutedText,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
