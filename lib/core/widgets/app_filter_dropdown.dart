import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_options_menu.dart';

class AppFilterDropdown<T> extends StatelessWidget {
  const AppFilterDropdown({
    super.key,
    required this.value,
    required this.options,
    required this.labelOf,
    required this.onSelected,
    this.width,
    this.menuWidth = appOptionsMenuWidth,
  });

  static const double _minWidth = 115;
  static const double _leftPadding = 20;
  static const double _height = 42;
  static const double _chevronSize = 18;
  static const double _labelGap = 10;

  final T value;
  final List<T> options;
  final String Function(T option) labelOf;
  final ValueChanged<T> onSelected;
  final double? width;
  final double menuWidth;

  Future<void> _openMenu(BuildContext context) async {
    final selected = await showAppOptionsMenu<T>(
      anchorContext: context,
      options: options,
      labelOf: labelOf,
      width: menuWidth,
    );
    if (selected != null) onSelected(selected);
  }

  @override
  Widget build(BuildContext context) {
    final label = Text(
      labelOf(value),
      style: AppTextStyles.labelSmall.copyWith(
        color: AppColors.menuText,
        fontWeight: FontWeight.w500,
      ),
    );

    return Material(
      color: AppColors.surface,
      borderRadius: AppUtils.radiusSmall,
      child: InkWell(
        onTap: () => _openMenu(context),
        borderRadius: AppUtils.radiusSmall,
        child: Container(
          width: width,
          constraints: const BoxConstraints(
            minWidth: _minWidth,
            minHeight: _height,
          ),
          padding: const EdgeInsets.only(
            left: _leftPadding,
            right: AppUtils.spacingLg,
          ),
          decoration: BoxDecoration(
            borderRadius: AppUtils.radiusSmall,
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (width == null) label else Expanded(child: label),
              const SizedBox(width: _labelGap),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: _chevronSize,
                color: AppColors.textLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
