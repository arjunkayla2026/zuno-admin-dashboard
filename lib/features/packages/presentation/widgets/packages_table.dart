import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zuno_admin_dashboard/core/enums/app_status.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_data_table.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_badge.dart';
import 'package:zuno_admin_dashboard/features/packages/data/models/package_plan.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/widgets/package_flow.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/widgets/package_offer_tag.dart';

class PackagesTable extends StatelessWidget {
  const PackagesTable({super.key, required this.packages});

  static const double _editIconSize = 12;
  static const List<AppTableColumn> _columns = [
    AppTableColumn(AppStrings.payableAmount, 158, alignEnd: true),
    AppTableColumn(AppStrings.receivableAmount, 199, alignEnd: true),
    AppTableColumn(AppStrings.receivableCoin, 170, alignEnd: true),
    AppTableColumn('', 28),
    AppTableColumn(AppStrings.offerTag, 162),
    AppTableColumn(AppStrings.offerPercentage, 110),
    AppTableColumn(AppStrings.status, 120),
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
              NumberFormatter.rupeesAmount(plan.payableAmount),
              style: AppTextStyles.labelLarge.copyWith(color: textColor),
            ),
            Text(
              NumberFormatter.rupeesAmount(plan.receivableAmount),
              style: cell,
            ),
            Text(NumberFormatter.grouped(plan.coins), style: strong),
            const SizedBox.shrink(),
            plan.hasOfferTag
                ? PackageOfferTag(label: plan.offerTag)
                : Text(AppStrings.emptyValue, style: muted),
            plan.hasOfferPercentage
                ? Text(
                    AppStrings.offerPercentValue(
                      NumberFormatter.trimmedAmount(plan.offerPercentage),
                    ),
                    style: strong,
                  )
                : Text(AppStrings.emptyValue, style: muted),
            AppStatusBadge(
              label: plan.isActive ? AppStrings.active : AppStrings.inactive,
              status: plan.isActive ? AppStatus.active : AppStatus.inactive,
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
