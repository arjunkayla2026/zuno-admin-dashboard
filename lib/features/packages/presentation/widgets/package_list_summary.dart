import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/widgets/package_flow.dart';

class PackageListSummary extends StatelessWidget {
  const PackageListSummary({
    super.key,
    required this.packageCount,
    required this.activeCount,
  });

  static const EdgeInsets _padding = EdgeInsets.fromLTRB(16, 12, 16, 12);

  final int packageCount;
  final int activeCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _padding,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppUtils.spacingMd,
        runSpacing: AppUtils.spacingSm,
        children: [
          Text(
            AppStrings.packagesSummary(packageCount, activeCount),
            style: AppTextStyles.bodySmall.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
          AppPrimaryButton(
            label: AppStrings.addPackage,
            icon: Icons.add_rounded,
            compact: true,
            onPressed: () => openPackageSheet(context),
          ),
        ],
      ),
    );
  }
}
