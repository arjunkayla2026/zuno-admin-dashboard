import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';

class PasswordVisibilityToggle extends StatelessWidget {
  const PasswordVisibilityToggle({
    super.key,
    required this.obscured,
    required this.onPressed,
  });

  final bool obscured;
  final VoidCallback onPressed;

  /// Toggles visibility without changing `obscureText` on a live text input
  /// connection.
  ///
  /// On Flutter Web, changing `obscureText` while the field is focused sends
  /// `TextInput.updateConfig`, which rebuilds the engine's autofill form and
  /// detaches the hidden DOM input, so the field stops accepting typing. The
  /// focused field is unfocused first (closing the connection), the toggle is
  /// applied, and focus is restored after the rebuild with a fresh connection.
  void _toggle() {
    final focused = FocusManager.instance.primaryFocus;
    final isTextField =
        focused?.context?.findAncestorStateOfType<EditableTextState>() != null;
    if (focused == null || !isTextField) {
      onPressed();
      return;
    }
    focused.unfocus();
    onPressed();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (focused.context != null) focused.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppUtils.spacingSm),
      child: TextButton(
        onPressed: _toggle,
        style: TextButton.styleFrom(
          foregroundColor: context.appColors.textSecondary,
          textStyle: AppTextStyles.labelSmall,
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(horizontal: AppUtils.spacingXs),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: IndexedStack(
          index: obscured ? 0 : 1,
          alignment: Alignment.center,
          children: const [Text(AppStrings.show), Text(AppStrings.hide)],
        ),
      ),
    );
  }
}
