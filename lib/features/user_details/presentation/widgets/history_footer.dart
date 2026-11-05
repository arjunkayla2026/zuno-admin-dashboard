import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';

class HistoryFooter extends StatelessWidget {
  const HistoryFooter({super.key, required this.shown, required this.total});

  static const double _height = 35;
  static const double _sidePadding = 16;

  final int shown;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: _sidePadding),
      child: Text(
        shown == 0
            ? AppStrings.noRecordsFound
            : AppStrings.showingOf(shown, total),
        style: AppTextStyles.tableFootnote.copyWith(
          color: context.appColors.textSecondary,
        ),
      ),
    );
  }
}
