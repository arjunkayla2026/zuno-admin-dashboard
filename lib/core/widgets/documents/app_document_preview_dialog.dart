import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_close_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_dialog_surface.dart';

Future<void> showAppDocumentPreview({
  required BuildContext context,
  required String title,
  required double aspectRatio,
  required Widget preview,
}) {
  return showAppDialog<void>(
    context: context,
    builder: (_) => AppDocumentPreviewDialog(
      title: title,
      aspectRatio: aspectRatio,
      preview: preview,
    ),
  );
}

class AppDocumentPreviewDialog extends StatelessWidget {
  const AppDocumentPreviewDialog({
    super.key,
    required this.title,
    required this.aspectRatio,
    required this.preview,
  });

  static const double _width = 640;
  static const double _closeSize = 32;
  static const double _closeIconSize = 16;
  static const double _headerGap = 14;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(16, 16, 16, 16);

  final String title;
  final double aspectRatio;
  final Widget preview;

  @override
  Widget build(BuildContext context) {
    return AppDialogSurface(
      width: _width,
      padding: _padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: AppUtils.spacingMd),
              AppCloseButton(
                size: _closeSize,
                iconSize: _closeIconSize,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: _headerGap),
          Flexible(
            child: ClipRRect(
              borderRadius: AppUtils.radiusSmall,
              child: AspectRatio(aspectRatio: aspectRatio, child: preview),
            ),
          ),
        ],
      ),
    );
  }
}
