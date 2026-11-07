import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';

typedef PackagePreview = ({int price, int coins, String offer});

class PackagePreviewCard extends StatelessWidget {
  const PackagePreviewCard({super.key, required this.preview});

  static const double _width = 160;
  static const double _headerHeight = 42;
  static const double _offerRadius = 10;
  static const EdgeInsets _bodyPadding = EdgeInsets.fromLTRB(10, 14, 10, 12);
  static const EdgeInsets _offerPadding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 2,
  );
  static const String _rupee = '₹';

  final PackagePreview? preview;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final current = preview;
    final price = current == null
        ? '$_rupee${AppStrings.previewBlank}'
        : NumberFormatter.rupees(current.price);
    final coins = current == null
        ? AppStrings.previewBlank
        : NumberFormatter.grouped(current.coins);
    final offer = current == null
        ? AppStrings.previewOfferBlank
        : current.offer.trim();

    return Container(
      width: _width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.uploadBackground,
        borderRadius: AppUtils.radiusSmall,
        border: Border.all(color: colors.uploadBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: _headerHeight,
            alignment: Alignment.center,
            color: AppColors.primary,
            child: Text(
              price,
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.onPrimaryButton,
              ),
            ),
          ),
          Padding(
            padding: _bodyPadding,
            child: Column(
              children: [
                Text(
                  coins,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: colors.onPrimarySoft,
                  ),
                ),
                Text(
                  AppStrings.coinsLabel,
                  style: AppTextStyles.captionSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                if (offer.isNotEmpty) ...[
                  const SizedBox(height: AppUtils.spacingXs),
                  Container(
                    padding: _offerPadding,
                    decoration: BoxDecoration(
                      color: colors.onPrimarySoft,
                      borderRadius: BorderRadius.circular(_offerRadius),
                    ),
                    child: Text(
                      offer,
                      style: AppTextStyles.captionSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
