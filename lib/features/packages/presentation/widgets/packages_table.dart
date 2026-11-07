import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_data_table.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/features/packages/data/models/package_plan.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/widgets/package_flow.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/widgets/package_offer_tag.dart';

class PackagesTable extends StatelessWidget {
  const PackagesTable({super.key, required this.packages});

  static const double _countWidth = 170;
  static const double _editIconSize = 12;
  static const List<AppTableColumn> _columns = [
    AppTableColumn(AppStrings.payableAmount, 158, alignEnd: true),
    AppTableColumn(AppStrings.receivableAmount, 199, alignEnd: true),
    AppTableColumn(AppStrings.receivableCoin, 170, alignEnd: true),
    AppTableColumn('', 28),
    AppTableColumn(AppStrings.offer, 162),
    AppTableColumn(AppStrings.tagline, 148),
    AppTableColumn(AppStrings.packageRechargeCount, 220),
    AppTableColumn('', 100, alignEnd: true),
  ];

  final List<PackagePlan> packages;

  @override
  Widget build(BuildContext context) {
    final textColor = context.colorScheme.onSurface;
    final cell = AppTextStyles.bodySmall.copyWith(color: textColor);
    final strong = cell.copyWith(fontWeight: FontWeight.w700);
    final muted = cell.copyWith(color: context.appColors.textSecondary);

    return AppDataTable(
      columns: _columns,
      rows: [
        for (final plan in packages)
          [
            Text(
              NumberFormatter.rupees(plan.payableAmount),
              style: AppTextStyles.labelLarge.copyWith(color: textColor),
            ),
            Text(NumberFormatter.rupees(plan.receivableAmount), style: cell),
            Text(NumberFormatter.grouped(plan.coins), style: strong),
            const SizedBox.shrink(),
            plan.hasOffer
                ? PackageOfferTag(label: plan.offer)
                : Text(AppStrings.emptyValue, style: muted),
            Text(plan.tagline, style: cell),
            SizedBox(
              width: _countWidth,
              child: Text(
                NumberFormatter.grouped(plan.totalRecharges),
                textAlign: TextAlign.center,
                style: strong,
              ),
            ),
            AppSecondaryButton(
              label: AppStrings.edit,
              small: true,
              onPressed: () => openPackageSheet(context, plan: plan),
              leading: SvgPicture.asset(
                AppImages.editIcon,
                width: _editIconSize,
                height: _editIconSize,
                colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
              ),
            ),
          ],
      ],
    );
  }
}
