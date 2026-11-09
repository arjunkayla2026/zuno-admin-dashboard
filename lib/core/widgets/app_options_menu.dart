import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_anchored_menu.dart';

const double _menuItemHeight = 42;
const double _menuPadding = 8;
const double appOptionsMenuWidth = 170;
const Offset _menuOffset = Offset(8, 16);

Future<T?> showAppOptionsMenu<T>({
  required BuildContext anchorContext,
  required List<T> options,
  required String Function(T option) labelOf,
  double width = appOptionsMenuWidth,
}) {
  final height = _menuItemHeight * options.length + _menuPadding * 2;

  return showAnchoredMenu<T>(
    anchorContext: anchorContext,
    size: Size(width, height),
    position: (anchor) => Offset(
      anchor.right + _menuOffset.dx - width,
      anchor.bottom + _menuOffset.dy,
    ),
    builder: (menuContext) => Padding(
      padding: const EdgeInsets.symmetric(vertical: _menuPadding),
      child: Column(
        children: [
          for (final option in options)
            InkWell(
              onTap: () => Navigator.of(menuContext).pop(option),
              child: Container(
                height: _menuItemHeight,
                alignment: Alignment.center,
                child: Text(
                  labelOf(option),
                  style: AppTextStyles.menuItem.copyWith(
                    color: AppColors.menuText,
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
