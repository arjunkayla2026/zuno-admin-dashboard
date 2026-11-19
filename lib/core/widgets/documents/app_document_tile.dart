import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';

class AppDocumentTile extends StatelessWidget {
  const AppDocumentTile({
    super.key,
    required this.label,
    required this.preview,
    required this.onTap,
    this.pageCount = 1,
  });

  static const double _previewAspectRatio = 1.4;
  static const double _badgeInset = 6;
  static const double _badgeIconSize = 12;
  static const double _badgeIconGap = 4;
  static const EdgeInsets _badgePadding = EdgeInsets.symmetric(
    horizontal: 6,
    vertical: 2,
  );
  static const EdgeInsets _labelPadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 9,
  );

  final String label;
  final Widget preview;
  final VoidCallback onTap;

  /// How many files the tile opens, e.g. 2 for an Aadhaar card whose
  /// preview slides between front and back. Above 1, the preview shows a
  /// `1/count` badge.
  final int pageCount;

  Widget _pageBadge() {
    return Tooltip(
      message: AppStrings.documentPagesHint(pageCount),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.mediaOverlay,
          borderRadius: AppUtils.radiusSmall,
        ),
        child: Padding(
          padding: _badgePadding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.collections_outlined,
                size: _badgeIconSize,
                color: AppColors.onMediaOverlay,
              ),
              const SizedBox(width: _badgeIconGap),
              Text(
                AppStrings.documentPageCount(1, pageCount),
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColors.onMediaOverlay,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTheme.radiusField);

    return Material(
      color: context.colorScheme.surface,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: _previewAspectRatio,
                child: pageCount > 1
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          preview,
                          Positioned(
                            top: _badgeInset,
                            right: _badgeInset,
                            child: _pageBadge(),
                          ),
                        ],
                      )
                    : preview,
              ),
              Padding(
                padding: _labelPadding,
                child: Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
