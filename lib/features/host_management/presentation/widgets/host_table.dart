import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/admin_host.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/widgets/host_table_columns.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/widgets/host_table_row.dart';

class HostTable extends StatelessWidget {
  const HostTable({super.key, required this.hosts});

  static const double _headerHeight = 38;

  final List<AdminHost> hosts;

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
              child: HostTableColumns(
                createdDate: Text(AppStrings.createdDate, style: style),
                name: Text(AppStrings.name, style: style),
                hostId: Text(AppStrings.hostId, style: style),
                phone: Text(AppStrings.phoneNumber, style: style),
                status: Text(AppStrings.status, style: style),
                wallet: Text(AppStrings.walletBalance, style: style),
                action: Text(AppStrings.takeAction, style: style),
              ),
            ),
            for (final host in hosts) HostTableRow(host: host),
          ],
        );

        if (constraints.maxWidth >= HostTableColumns.minWidth) return table;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(width: HostTableColumns.minWidth, child: table),
        );
      },
    );
  }
}
