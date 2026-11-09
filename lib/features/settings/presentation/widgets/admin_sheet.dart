import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_nav_item.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_choice_chips.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_error_banner.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_field_row.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_labeled_dropdown_field.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_labeled_text_field.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_read_only_field.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_side_sheet.dart';
import 'package:zuno_admin_dashboard/core/widgets/password_visibility_toggle.dart';
import 'package:zuno_admin_dashboard/core/data/admin_account.dart';

class AdminSheet extends StatefulWidget {
  const AdminSheet({super.key, this.admin, required this.onSave});

  final AdminAccount? admin;
  final Future<String?> Function(AdminAccount admin, String? password) onSave;

  @override
  State<AdminSheet> createState() => _AdminSheetState();
}

class _AdminSheetState extends State<AdminSheet> {
  static const double _fieldGap = 14;
  static const double _helperGap = 4;
  static const double _chipsGap = 10;
  static const int _minPhoneDigits = 10;

  late final _nameController = TextEditingController(
    text: widget.admin?.name ?? '',
  );
  late final _emailController = TextEditingController(
    text: widget.admin?.email ?? '',
  );
  late final _phoneController = TextEditingController(
    text: widget.admin?.phone ?? '',
  );
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AdminRole _role = widget.admin?.role ?? AdminRole.supportAdmin;
  late Set<AdminNavItem> _modules = {...?widget.admin?.modules};
  bool _submitted = false;
  bool _saving = false;
  String? _errorMessage;

  bool get _nameValid => _nameController.text.trim().isNotEmpty;

  bool get _emailValid => AppUtils.isValidEmail(_emailController.text);

  bool get _phoneValid =>
      _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '').length >=
      _minPhoneDigits;

  bool get _isAdding => widget.admin == null;

  String get _password => _passwordController.text;

  bool get _passwordValid =>
      (!_isAdding && _password.isEmpty) ||
      _password.length >= AdminAccount.minPasswordLength;

  bool get _modulesValid =>
      _role == AdminRole.superAdmin || _modules.isNotEmpty;

  String? _error(bool valid, String message) =>
      _submitted && !valid ? message : null;

  Future<void> _save() async {
    if (!_nameValid ||
        !_emailValid ||
        !_phoneValid ||
        !_passwordValid ||
        !_modulesValid) {
      setState(() => _submitted = true);
      return;
    }
    final admin = AdminAccount(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      role: _role,
      phone: _phoneController.text.trim(),
      modules: [
        for (final item in AdminNavItem.values)
          if (_modules.contains(item)) item,
      ],
      createdAt: widget.admin?.createdAt,
    );
    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    final error = await widget.onSave(
      admin,
      _password.isEmpty ? null : _password,
    );
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop(admin);
      return;
    }
    setState(() {
      _saving = false;
      _errorMessage = error;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.admin != null;
    final formLabel = AppTextStyles.formLabel.copyWith(
      color: AppColors.segmentText,
    );
    final muted = context.appColors.textSecondary;
    final modulesError = _error(_modulesValid, AppStrings.chooseModule);

    return AppSideSheet(
      title: isEditing ? AppStrings.editAdmin : AppStrings.addAdmin,
      subtitle: isEditing
          ? AppStrings.editAdminSubtitle
          : AppStrings.addAdminSubtitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppLabeledTextField(
            label: AppStrings.name,
            labelStyle: formLabel,
            hint: '',
            controller: _nameController,
            textInputAction: TextInputAction.next,
            errorText: _error(_nameValid, AppStrings.enterName),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: _fieldGap),
          AppFieldRow(
            first: isEditing
                ? AppReadOnlyField(
                    label: AppStrings.email,
                    value: _emailController.text,
                  )
                : AppLabeledTextField(
                    label: AppStrings.email,
                    labelStyle: formLabel,
                    hint: '',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    errorText: _error(_emailValid, AppStrings.enterValidEmail),
                    onChanged: (_) => setState(() {}),
                  ),
            second: AppLabeledTextField(
              label: AppStrings.phoneNumber,
              labelStyle: formLabel,
              hint: '',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
              ],
              errorText: _error(_phoneValid, AppStrings.enterValidPhone),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: _fieldGap),
          AppLabeledTextField(
            label: AppStrings.password,
            labelStyle: formLabel,
            hint: '',
            controller: _passwordController,
            obscureText: _obscurePassword,
            autofillHints: const [AutofillHints.newPassword],
            textInputAction: TextInputAction.next,
            errorText: _error(_passwordValid, AppStrings.passwordTooShort),
            onChanged: (_) => setState(() {}),
            suffix: PasswordVisibilityToggle(
              obscured: _obscurePassword,
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: _helperGap),
          Text(
            _isAdding
                ? AppStrings.adminPasswordHelper
                : AppStrings.editAdminPasswordHelper,
            style: AppTextStyles.captionSmall.copyWith(color: muted),
          ),
          const SizedBox(height: _fieldGap),
          AppLabeledDropdownField<AdminRole>(
            label: AppStrings.role,
            labelStyle: formLabel,
            hint: AppStrings.role,
            value: _role,
            options: AdminRole.values,
            labelOf: (role) => role.label,
            onChanged: (role) {
              if (role != null) setState(() => _role = role);
            },
          ),
          const SizedBox(height: _fieldGap),
          Text(AppStrings.permissions, style: formLabel),
          const SizedBox(height: _helperGap),
          Text(
            AppStrings.permissionsHelper,
            style: AppTextStyles.captionSmall.copyWith(color: muted),
          ),
          const SizedBox(height: _chipsGap),
          AppChoiceChips<AdminNavItem>(
            options: AdminNavItem.values,
            selected: _modules,
            labelOf: (item) => item.label,
            labelStyle: formLabel,
            onChanged: (modules) => setState(() => _modules = modules),
          ),
          if (modulesError != null) ...[
            const SizedBox(height: _helperGap),
            Text(
              modulesError,
              style: AppTextStyles.captionSmall.copyWith(
                color: context.colorScheme.error,
              ),
            ),
          ],
          if (_errorMessage case final message?) ...[
            const SizedBox(height: _fieldGap),
            AppErrorBanner(message: message),
          ],
        ],
      ),
      footer: Wrap(
        spacing: AppUtils.spacingSm,
        runSpacing: AppUtils.spacingSm,
        children: [
          AppSecondaryButton(
            label: AppStrings.cancel,
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppPrimaryButton(
            label: _saving ? AppStrings.saving : AppStrings.saveAdmin,
            compact: true,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}
