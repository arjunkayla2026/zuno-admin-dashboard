import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/banner_image.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/banner_preview.dart';

class BannerCard extends StatelessWidget {
  const BannerCard({
    super.key,
    required this.number,
    required this.banner,
    required this.onDelete,
  });

  static const double _deleteIconSize = 14;
  static const double _deleteIconGap = 6;
  static const double _metaGap = 2;
  static const double _actionGap = 12;
  static const EdgeInsets _footerPadding = EdgeInsets.fromLTRB(15, 10, 14, 10);

  final int number;
  final BannerImage banner;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BannerPreview(banner: banner),
          Padding(
            padding: _footerPadding,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.bannerName(number),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: context.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: _metaGap),
                      Text(
                        AppStrings.bannerMeta(
                          banner.fileName,
                          DateFormatter.short(banner.addedOn),
                        ),
                        style: AppTextStyles.tableFootnote.copyWith(
                          color: context.appColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: _actionGap),
                AppSecondaryButton(
                  label: AppStrings.delete,
                  small: true,
                  destructive: true,
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    size: _deleteIconSize,
                  ),
                  leadingGap: _deleteIconGap,
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
