import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_nav_item.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_choice_chips.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_table_checkbox.dart';

class AdminPermissionsField extends StatelessWidget {
  const AdminPermissionsField({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.labelStyle,
    this.enabled = true,
    this.errorText,
  });

  static const double _helperGap = 4;
  static const double _chipsGap = 10;
  static const double _checkboxGap = 6;

  final Set<AdminNavItem> selected;
  final ValueChanged<Set<AdminNavItem>> onChanged;
  final TextStyle labelStyle;
  final bool enabled;
  final String? errorText;

  bool? get _allState {
    if (selected.length == AdminNavItem.values.length) return true;
    return selected.isEmpty ? false : null;
  }

  void _toggleAll() => onChanged(
    _allState == true ? <AdminNavItem>{} : {...AdminNavItem.values},
  );

  @override
  Widget build(BuildContext context) {
    final muted = context.appColors.textSecondary;
    final caption = AppTextStyles.captionSmall.copyWith(color: muted);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AppStrings.permissions, style: labelStyle),
        const SizedBox(height: _helperGap),
        Text(
          enabled
              ? AppStrings.permissionsHelper
              : AppStrings.superAdminAllModules,
          style: caption,
        ),
        const SizedBox(height: _chipsGap),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: InkWell(
            onTap: enabled ? _toggleAll : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTableCheckbox(
                  value: _allState,
                  onToggle: enabled ? _toggleAll : null,
                ),
                const SizedBox(width: _checkboxGap),
                Flexible(
                  child: Text(AppStrings.selectAllModules, style: labelStyle),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: _chipsGap),
        AppChoiceChips<AdminNavItem>(
          options: AdminNavItem.values,
          selected: selected,
          labelOf: (item) => item.label,
          labelStyle: labelStyle,
          enabled: enabled,
          onChanged: onChanged,
        ),
        if (errorText case final error?) ...[
          const SizedBox(height: _helperGap),
          Text(
            error,
            style: AppTextStyles.captionSmall.copyWith(
              color: context.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
