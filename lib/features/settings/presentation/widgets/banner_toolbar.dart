import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/banner_image.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/banner_flow.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/banner_labels.dart';

class BannerToolbar extends StatelessWidget {
  const BannerToolbar({super.key, required this.banners});

  static const EdgeInsets _padding = EdgeInsets.fromLTRB(20, 14, 20, 14);
  static const EdgeInsets _badgePadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 3,
  );
  static const double _badgeRadius = 8;

  final List<BannerImage> banners;

  int _countOn(BannerScreen screen) =>
      banners.where((banner) => banner.screen == screen).length;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: _padding,
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: AppUtils.spacingSm,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppUtils.spacingMd,
              runSpacing: AppUtils.spacingXs,
              children: [
                Text(
                  AppStrings.screenPlacement,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: context.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                for (final screen in BannerScreen.values)
                  Container(
                    padding: _badgePadding,
                    decoration: BoxDecoration(
                      color: colors.primarySoft,
                      borderRadius: BorderRadius.circular(_badgeRadius),
                    ),
                    child: Text(
                      AppStrings.bannerScreenCount(
                        BannerLabels.screen(screen),
                        _countOn(screen),
                      ),
                      style: AppTextStyles.captionSmall.copyWith(
                        color: colors.onPrimarySoft,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Text(
                  AppStrings.bannersSummary(banners.length),
                  style: AppTextStyles.tableFootnote.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
            Builder(
              builder: (buttonContext) => AppPrimaryButton(
                label: AppStrings.addBanner,
                icon: Icons.add_rounded,
                compact: true,
                onPressed: () => openAddBannerDialog(buttonContext),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
