import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';

Future<T?> showAnchoredMenu<T>({
  required BuildContext anchorContext,
  required Size size,
  required Offset Function(Rect anchor) position,
  required WidgetBuilder builder,
}) {
  final box = anchorContext.findRenderObject()! as RenderBox;
  final anchor = box.localToGlobal(Offset.zero) & box.size;

  return showGeneralDialog<T>(
    context: anchorContext,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(anchorContext)
        .modalBarrierDismissLabel,
    barrierColor: AppColors.modalScrim,
    transitionDuration: Duration.zero,
    pageBuilder: (context, _, _) {
      final screen = MediaQuery.sizeOf(context);
      final origin = position(anchor);
      final maxLeft = screen.width - size.width - AppUtils.spacingSm;
      final maxTop = screen.height - size.height - AppUtils.spacingSm;

      return Stack(
        children: [
          Positioned(
            left: origin.dx.clamp(AppUtils.spacingSm, maxLeft),
            top: origin.dy.clamp(AppUtils.spacingSm, maxTop),
            width: size.width,
            height: size.height,
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: context.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMenu),
                  boxShadow: AppColors.menuShadows,
                ),
                child: builder(context),
              ),
            ),
          ),
        ],
      );
    },
  );
}
