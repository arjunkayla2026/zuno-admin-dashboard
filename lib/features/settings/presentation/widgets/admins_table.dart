import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_data_table.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_initials_avatar.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_badge.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/admin_account.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/admin_flow.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/admin_labels.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/admin_permission_tag.dart';

class AdminsTable extends StatelessWidget {
  const AdminsTable({super.key, required this.admins});

  static const double _avatarSize = 26;
  static const double _avatarGap = 8;
  static const double _tagSpacing = 6;
  static const double _editIconSize = 12;

  static const List<AppTableColumn> _columns = [
    AppTableColumn(AppStrings.name, 160),
    AppTableColumn(AppStrings.email, 180),
    AppTableColumn(AppStrings.role, 142),
    AppTableColumn(AppStrings.phoneNumber, 141),
    AppTableColumn(AppStrings.permissions, 380),
    AppTableColumn('', 80, alignEnd: true),
  ];

  final List<AdminAccount> admins;

  Widget _nameCell(BuildContext context, AdminAccount admin) {
    return Row(
      children: [
        AppInitialsAvatar(
          initials: admin.initials,
          color: AppColors.avatarNavy,
          size: _avatarSize,
          textStyle: AppTextStyles.captionSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: _avatarGap),
        Expanded(
          child: Text(
            admin.name,
            style: AppTextStyles.bodySmall.copyWith(
              color: context.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _permissions(AdminAccount admin) {
    if (admin.hasAllModules) {
      return const AdminPermissionTag(
        label: AppStrings.allModules,
        highlighted: true,
      );
    }
    return Wrap(
      spacing: _tagSpacing,
      runSpacing: _tagSpacing,
      children: [
        for (final module in admin.modules)
          AdminPermissionTag(label: module.label),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = context.colorScheme.onSurface;
    final cell = AppTextStyles.bodySmall.copyWith(color: textColor);
    final mono = AppTextStyles.monoSmall.copyWith(color: textColor);

    return AppDataTable(
      columns: _columns,
      rows: [
        for (final admin in admins)
          [
            _nameCell(context, admin),
            Text(admin.email, style: cell),
            () {
              final (label, status) = AdminLabels.role(admin.role);
              return AppStatusBadge(label: label, status: status);
            }(),
            Text(admin.phone, style: mono),
            _permissions(admin),
            AppSecondaryButton(
              label: AppStrings.edit,
              small: true,
              leading: SvgPicture.asset(
                AppImages.editIcon,
                width: _editIconSize,
                height: _editIconSize,
                colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
              ),
              onPressed: () => openAdminSheet(context, admin: admin),
            ),
          ],
      ],
    );
  }
}
