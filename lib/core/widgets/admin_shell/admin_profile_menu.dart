import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/di/injection_container.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_initials_avatar.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_options_menu.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/state/auth_cubit.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/state/auth_state.dart';

class AdminProfileMenu extends StatelessWidget {
  const AdminProfileMenu({
    super.key,
    required this.userName,
    required this.userRole,
    required this.userInitials,
  });

  final String userName;
  final String userRole;
  final String userInitials;

  void _onAuthChanged(BuildContext context, AuthState state) {
    if (state.status == AuthStatus.signedOut) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
      return;
    }
    if (state.errorMessage case final message?) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthCubit>(),
      child: BlocListener<AuthCubit, AuthState>(
        listener: _onAuthChanged,
        child: _ProfileChip(
          userName: userName,
          userRole: userRole,
          userInitials: userInitials,
        ),
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({
    required this.userName,
    required this.userRole,
    required this.userInitials,
  });

  static const double _avatarSize = 34;
  static const double _chevronSize = 20;
  static const double _chevronGap = 10;

  final String userName;
  final String userRole;
  final String userInitials;

  Future<void> _openMenu(BuildContext context) async {
    final selected = await showAppOptionsMenu<String>(
      anchorContext: context,
      options: const [AppStrings.logout],
      labelOf: (option) => option,
    );
    if (selected == null || !context.mounted) return;
    await context.read<AuthCubit>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppTheme.radiusSmall);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => _openMenu(context),
        borderRadius: borderRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppUtils.spacingSm,
            vertical: AppUtils.spacingXs,
          ),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppInitialsAvatar(
                initials: userInitials,
                color: AppColors.avatarNavy,
                size: _avatarSize,
              ),
              const SizedBox(width: AppUtils.spacingSm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: AppTextStyles.profileName.copyWith(
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    userRole,
                    style: AppTextStyles.captionSmall.copyWith(
                      color: context.appColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: _chevronGap),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: _chevronSize,
                color: context.colorScheme.onSurface,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
