import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_action_menu.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_initials_avatar.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_meta_field.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_profile_menu_button.dart';
import 'package:zuno_admin_dashboard/features/host_details/data/mock/host_details_mock_data.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/state/host_details_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/widgets/host_presence_status.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/admin_host.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/widgets/host_action_flow.dart';

class HostProfileCard extends StatelessWidget {
  const HostProfileCard({super.key, required this.host});

  static const double _avatarSize = 82;
  static const double _avatarRadius = 16;
  static const double _avatarGap = 22;
  static const double _metaGap = 18;
  static const double _metaSpacing = 28;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(22, 20, 20, 22);

  final AdminHost host;

  void _onAction(BuildContext context, AppMenuAction action) {
    final cubit = context.read<HostDetailsCubit>();
    runHostAction(
      context: context,
      action: action,
      host: cubit.state.host,
      onHostChanged: cubit.updateHost,
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = AppColors.avatarPalette;
    final textColor = context.colorScheme.onSurface;

    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppInitialsAvatar(
                initials: host.initials,
                color: palette[host.avatarIndex % palette.length],
                size: _avatarSize,
                borderRadius: BorderRadius.circular(_avatarRadius),
                textStyle: AppTextStyles.headlineMedium,
              ),
              const SizedBox(width: _avatarGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      host.name,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: textColor,
                      ),
                    ),
                    Text(
                      host.fullName,
                      style: AppTextStyles.captionSmall.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (host.hasActions)
                AppProfileMenuButton(
                  actions: AppActionMenu.accountActions(
                    isBlocked: host.status == HostStatus.blocked,
                  ),
                  onSelected: (action) => _onAction(context, action),
                ),
            ],
          ),
          const SizedBox(height: _metaGap),
          Wrap(
            spacing: _metaSpacing,
            runSpacing: AppUtils.spacingSm,
            children: [
              AppMetaField(
                label: AppStrings.hostId,
                value: host.hostId,
                minWidth: 82,
                mono: true,
              ),
              AppMetaField(
                label: AppStrings.accountCreatedDate,
                value: host.createdDate,
                minWidth: 110,
              ),
              AppMetaField(
                label: AppStrings.phoneNumber,
                value: host.phone,
                minWidth: 130,
                mono: true,
              ),
              const AppMetaField(
                label: AppStrings.status,
                minWidth: 70,
                valueWidget: HostPresenceStatus(
                  isOnline: HostDetailsMockData.isOnline,
                ),
              ),
              const AppMetaField(
                label: AppStrings.lastOnline,
                value: HostDetailsMockData.lastOnline,
                minWidth: 150,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
