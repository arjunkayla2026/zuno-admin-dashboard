import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';

class AppDocumentTile extends StatelessWidget {
  const AppDocumentTile({
    super.key,
    required this.label,
    required this.preview,
    required this.onTap,
  });

  static const double _previewAspectRatio = 1.4;
  static const EdgeInsets _labelPadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 9,
  );

  final String label;
  final Widget preview;
  final VoidCallback onTap;

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
              AspectRatio(aspectRatio: _previewAspectRatio, child: preview),
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
