import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_pagination.dart';

class AppTableFooter extends StatelessWidget {
  const AppTableFooter({
    super.key,
    required this.firstIndex,
    required this.shownCount,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  static const double _height = 50;

  final int firstIndex;
  final int shownCount;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: _height),
      padding: const EdgeInsets.symmetric(
        horizontal: AppUtils.spacingLg,
        vertical: AppUtils.spacingSm,
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: AppUtils.spacingSm,
        children: [
          Text(
            AppStrings.showingRange(
              firstIndex + 1,
              firstIndex + shownCount,
              totalCount,
            ),
            style: AppTextStyles.tableFootnote.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
          AppPagination(
            currentPage: currentPage,
            totalPages: totalPages,
            onPageChanged: onPageChanged,
          ),
        ],
      ),
    );
  }
}
