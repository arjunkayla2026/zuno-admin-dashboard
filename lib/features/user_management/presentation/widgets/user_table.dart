import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/widgets/user_table_columns.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/widgets/user_table_row.dart';

class UserTable extends StatelessWidget {
  const UserTable({super.key, required this.users});

  static const double _headerHeight = 38;

  final List<AdminUser> users;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.tableFootnote.copyWith(
      color: context.appColors.textSecondary,
      fontWeight: FontWeight.w500,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final table = Column(
          children: [
            Container(
              height: _headerHeight,
              decoration: const BoxDecoration(
                color: AppColors.tableHeaderBackground,
                border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
              ),
              child: UserTableColumns(
                createdDate: Text(AppStrings.createdDate, style: style),
                name: Text(AppStrings.name, style: style),
                userId: Text(AppStrings.userId, style: style),
                phone: Text(AppStrings.phoneNumber, style: style),
                recharges: Text(AppStrings.recharges, style: style),
                wallet: Text(AppStrings.walletBalance, style: style),
                action: Text(AppStrings.takeAction, style: style),
              ),
            ),
            for (final user in users) UserTableRow(user: user),
          ],
        );

        if (constraints.maxWidth >= UserTableColumns.minWidth) return table;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(width: UserTableColumns.minWidth, child: table),
        );
      },
    );
  }
}
