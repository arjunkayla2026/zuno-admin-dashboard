import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_profile_menu.dart';

class AdminTopBar extends StatelessWidget {
  const AdminTopBar({
    super.key,
    required this.userName,
    required this.userRole,
    required this.userInitials,
    this.title,
    this.breadcrumb,
    this.onMenuPressed,
    this.notice,
  });

  static const double _height = 74;
  static const double _horizontalPadding = 32;
  static const double _compactPadding = 16;
  static const double _breadcrumbIconSize = 13;
  static const double _breadcrumbGap = 4;

  final String userName;
  final String userRole;
  final String userInitials;
  final String? title;
  final List<String>? breadcrumb;
  final VoidCallback? onMenuPressed;
  final Widget? notice;

  @override
  Widget build(BuildContext context) {
    final isCompact = !AppUtils.isDesktop(context);

    return Container(
      constraints: const BoxConstraints(minHeight: _height),
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? _compactPadding : _horizontalPadding,
        vertical: AppUtils.spacingSm,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        border: const Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: [
          if (onMenuPressed != null)
            IconButton(
              onPressed: onMenuPressed,
              icon: const Icon(Icons.menu_rounded),
            ),
          Expanded(
            child: title == null
                ? const SizedBox.shrink()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (breadcrumb case final crumbs?)
                        Wrap(
                          spacing: _breadcrumbGap,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            for (final (index, crumb) in crumbs.indexed) ...[
                              if (index > 0)
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: _breadcrumbIconSize,
                                  color: context.appColors.textSecondary,
                                ),
                              Text(
                                crumb,
                                style: AppTextStyles.tableFootnote.copyWith(
                                  color: context.appColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      Text(
                        title!,
                        style: AppTextStyles.pageTitle.copyWith(
                          color: context.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
          ),
          if (notice case final notice?) ...[
            notice,
            const SizedBox(width: AppUtils.spacingLg),
          ],
          if (!isCompact) ...[
            Text(
              DateFormatter.long(DateTime.now()),
              style: AppTextStyles.bodySmall.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppUtils.spacingLg),
          ],
          AdminProfileMenu(
            userName: userName,
            userRole: userRole,
            userInitials: userInitials,
          ),
        ],
      ),
    );
  }
}
