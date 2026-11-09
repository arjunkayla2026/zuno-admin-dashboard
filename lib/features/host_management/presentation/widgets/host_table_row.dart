import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_initials_avatar.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_take_action_button.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/admin_host.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/host_details_arguments.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/host_management_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/widgets/host_action_flow.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/widgets/host_status_badges.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/widgets/host_table_columns.dart';

class HostTableRow extends StatelessWidget {
  const HostTableRow({super.key, required this.host});

  static const double _height = 55;
  static const double _avatarGap = 10;
  static const double _nameLineHeight = 1.25;
  static const double _subtitleLineHeight = 1.1;

  final AdminHost host;

  @override
  Widget build(BuildContext context) {
    final textColor = context.colorScheme.onSurface;
    final cell = AppTextStyles.tableCell.copyWith(color: textColor);
    final mono = AppTextStyles.mono.copyWith(color: textColor);
    const avatarColors = AppColors.avatarPalette;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(
          AppRoutes.hostDetails,
          arguments: HostDetailsArguments(
            host: host,
            onHostChanged: context.read<HostManagementCubit>().replaceHost,
          ),
        ),
        child: Container(
          constraints: const BoxConstraints(minHeight: _height),
          padding: const EdgeInsets.symmetric(vertical: AppUtils.spacingXs),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
          ),
          child: HostTableColumns(
            createdDate: Text(host.createdDate, style: cell),
            name: Row(
              children: [
                AppInitialsAvatar(
                  initials: host.initials,
                  color: avatarColors[host.avatarIndex % avatarColors.length],
                ),
                const SizedBox(width: _avatarGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        host.name,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          height: _nameLineHeight,
                        ),
                      ),
                      Text(
                        host.fullName,
                        style: AppTextStyles.captionSmall.copyWith(
                          color: context.appColors.textSecondary,
                          height: _subtitleLineHeight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            hostId: Text(host.hostId, style: mono),
            phone: Text(host.phone, style: mono),
            status: Align(
              alignment: Alignment.centerLeft,
              child: HostStatusBadges(host: host),
            ),
            wallet: Text(
              NumberFormatter.rupees(host.walletBalance),
              style: AppTextStyles.labelMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            action: host.hasActions
                ? AppTakeActionButton(
                    onSelected: (action) => runHostAction(
                      context: context,
                      action: action,
                      host: host,
                      onHostChanged: context
                          .read<HostManagementCubit>()
                          .replaceHost,
                    ),
                  )
                : Text(
                    AppStrings.noActions,
                    style: AppTextStyles.tableFootnote.copyWith(
                      color: AppColors.tableMutedText,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
