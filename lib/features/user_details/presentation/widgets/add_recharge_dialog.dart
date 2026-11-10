import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_dialog_surface.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/features/user_details/data/mock/user_details_mock_data.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/widgets/recharge_dialog_header.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/widgets/recharge_package_tile.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';

class AddRechargeDialog extends StatefulWidget {
  const AddRechargeDialog({super.key, required this.user});

  final AdminUser user;

  @override
  State<AddRechargeDialog> createState() => _AddRechargeDialogState();
}

class _AddRechargeDialogState extends State<AddRechargeDialog> {
  static const double _headerGap = 16;
  static const double _labelGap = 7;
  static const double _tileGap = 10;
  static const double _rowGap = 8;
  static const double _actionsGap = 24;
  static const double _actionSpacing = 10;
  static const double _twoColumnWidth = 360;
  static const EdgeInsets _padding = EdgeInsets.all(AppUtils.spacingXl);

  int _selectedIndex = UserDetailsMockData.defaultPackageIndex;

  @override
  Widget build(BuildContext context) {
    final packages = UserDetailsMockData.packages;
    final user = widget.user;

    return AppDialogSurface(
      padding: _padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RechargeDialogHeader(
            title: AppStrings.addRecharge,
            subtitle: AppStrings.rechargeSubtitle(user.name, user.userID),
          ),
          const SizedBox(height: _headerGap),
          Text(
            AppStrings.choosePackage,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.segmentText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: _labelGap),
          Flexible(
            child: SingleChildScrollView(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isTwoColumn = constraints.maxWidth >= _twoColumnWidth;
                  final width = isTwoColumn
                      ? (constraints.maxWidth - _tileGap) / 2
                      : constraints.maxWidth;

                  return Wrap(
                    spacing: _tileGap,
                    runSpacing: _rowGap,
                    children: [
                      for (final (index, package) in packages.indexed)
                        SizedBox(
                          width: width,
                          child: RechargePackageTile(
                            package: package,
                            selected: index == _selectedIndex,
                            onTap: () => setState(() => _selectedIndex = index),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: _actionsGap),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: _actionSpacing,
            runSpacing: AppUtils.spacingSm,
            children: [
              AppSecondaryButton(
                label: AppStrings.cancel,
                onPressed: () => Navigator.of(context).pop(),
              ),
              AppPrimaryButton(
                label: AppStrings.continueAction,
                compact: true,
                onPressed: () =>
                    Navigator.of(context).pop(packages[_selectedIndex]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
