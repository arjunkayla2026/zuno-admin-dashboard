import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_error_banner.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_labeled_text_field.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_profile_header.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_read_only_field.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_side_sheet.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';

typedef EditedUser = ({String name, String phone});

class EditUserSheet extends StatefulWidget {
  const EditUserSheet({super.key, required this.user, required this.onSave});

  final AdminUser user;
  final Future<String?> Function(EditedUser edited) onSave;

  @override
  State<EditUserSheet> createState() => _EditUserSheetState();
}

class _EditUserSheetState extends State<EditUserSheet> {
  static const double _profileGap = 21;
  static const double _fieldGap = 14;
  static const double _footerGap = 10;

  late final _nameController = TextEditingController(text: widget.user.name);
  late final _phoneController = TextEditingController(text: widget.user.phone);

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty &&
      _phoneController.text.trim().isNotEmpty;

  bool _saving = false;
  String? _errorMessage;

  void _onChanged(String _) => setState(() {});

  Future<void> _save() async {
    final EditedUser edited = (
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
    );
    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    final error = await widget.onSave(edited);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop(edited);
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
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return AppSideSheet(
      title: AppStrings.editUserDetails,
      subtitle: AppStrings.editUserSubtitle(user.userId, user.createdDate),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppProfileHeader(
            initials: user.initials,
            avatarIndex: user.avatarIndex,
            name: user.name,
            subtitle: user.userId,
          ),
          const SizedBox(height: _profileGap),
          AppLabeledTextField(
            label: AppStrings.userNameField,
            hint: AppStrings.userNameField,
            controller: _nameController,
            textInputAction: TextInputAction.next,
            onChanged: _onChanged,
            dense: true,
          ),
          const SizedBox(height: _fieldGap),
          AppLabeledTextField(
            label: AppStrings.registeredMobileNumber,
            hint: AppStrings.registeredMobileNumber,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            onChanged: _onChanged,
            dense: true,
          ),
          const SizedBox(height: _fieldGap),
          AppReadOnlyField(label: AppStrings.userId, value: user.userId),
          if (_errorMessage case final message?) ...[
            const SizedBox(height: _fieldGap),
            AppErrorBanner(message: message),
          ],
        ],
      ),
      footer: Wrap(
        spacing: _footerGap,
        runSpacing: AppUtils.spacingSm,
        children: [
          AppSecondaryButton(
            label: AppStrings.cancel,
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppPrimaryButton(
            label: _saving ? AppStrings.saving : AppStrings.saveChanges,
            compact: true,
            onPressed: _canSave && !_saving ? _save : null,
          ),
        ],
      ),
    );
  }
}
