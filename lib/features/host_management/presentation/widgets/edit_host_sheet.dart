import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_choice_chips.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_error_banner.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_field_row.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_labeled_dropdown_field.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_labeled_text_field.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_profile_header.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_side_sheet.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/admin_host.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/host_profile_options.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/widgets/host_profile_labels.dart';

class EditHostSheet extends StatefulWidget {
  const EditHostSheet({super.key, required this.host, required this.onSave});

  final AdminHost host;
  final Future<String?> Function(AdminHost edited) onSave;

  @override
  State<EditHostSheet> createState() => _EditHostSheetState();
}

class _EditHostSheetState extends State<EditHostSheet> {
  static const double _profileGap = 21;
  static const double _rowGap = 14;
  static const double _labelGap = 7;
  static const double _footerGap = 10;
  static final DateTime _firstBirthDate = DateTime(1940);

  late final _fullNameController = TextEditingController(
    text: widget.host.fullName,
  );
  late final _nickNameController = TextEditingController(
    text: widget.host.name,
  );
  late final _phoneController = TextEditingController(text: widget.host.phone);
  late final _districtController = TextEditingController(
    text: widget.host.district,
  );
  late final _stateController = TextEditingController(text: widget.host.state);
  late final _dateOfBirthController = TextEditingController(
    text: _formatDate(widget.host.dateOfBirth),
  );

  late DateTime? _dateOfBirth = widget.host.dateOfBirth;
  late HostGender? _gender = widget.host.gender;
  late HostLanguage? _motherTongue = widget.host.motherTongue;
  late Set<HostLanguage> _languages = widget.host.languages;
  bool _saving = false;
  String? _errorMessage;

  List<TextEditingController> get _controllers => [
    _fullNameController,
    _nickNameController,
    _phoneController,
    _districtController,
    _stateController,
    _dateOfBirthController,
  ];

  bool get _canSave => [
    _fullNameController,
    _nickNameController,
    _phoneController,
  ].every((controller) => controller.text.trim().isNotEmpty);

  static String _formatDate(DateTime? date) =>
      date == null ? '' : DateFormatter.short(date);

  void _onChanged(String _) => setState(() {});

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 20),
      firstDate: _firstBirthDate,
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      _dateOfBirth = picked;
      _dateOfBirthController.text = _formatDate(picked);
    });
  }

  Future<void> _save() async {
    final edited = widget.host.copyWith(
      fullName: _fullNameController.text.trim(),
      name: _nickNameController.text.trim(),
      phone: _phoneController.text.trim(),
      district: _districtController.text.trim(),
      state: _stateController.text.trim(),
      dateOfBirth: _dateOfBirth,
      gender: _gender,
      motherTongue: _motherTongue,
      languages: _languages,
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

  Widget _textField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return AppLabeledTextField(
      label: label,
      hint: label,
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      onChanged: _onChanged,
      dense: true,
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final host = widget.host;

    return AppSideSheet(
      title: AppStrings.editHostDetails,
      subtitle: AppStrings.editUserSubtitle(host.hostId, host.createdDate),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppProfileHeader(
            initials: host.initials,
            avatarIndex: host.avatarIndex,
            name: host.name,
            subtitle: host.hostId,
          ),
          const SizedBox(height: _profileGap),
          AppFieldRow(
            first: _textField(AppStrings.fullNameField, _fullNameController),
            second: _textField(AppStrings.nickNameField, _nickNameController),
          ),
          const SizedBox(height: _rowGap),
          AppFieldRow(
            first: _textField(
              AppStrings.mobileNumberField,
              _phoneController,
              keyboardType: TextInputType.phone,
            ),
            second: AppLabeledTextField(
              label: AppStrings.dateOfBirthField,
              hint: AppStrings.selectHint,
              controller: _dateOfBirthController,
              readOnly: true,
              onTap: _pickDateOfBirth,
              dense: true,
            ),
          ),
          const SizedBox(height: _rowGap),
          AppFieldRow(
            first: _textField(AppStrings.districtField, _districtController),
            second: _textField(AppStrings.stateField, _stateController),
          ),
          const SizedBox(height: _rowGap),
          AppFieldRow(
            first: AppLabeledDropdownField<HostGender>(
              label: AppStrings.genderField,
              hint: AppStrings.selectHint,
              value: _gender,
              options: HostGender.values,
              labelOf: HostProfileLabels.gender,
              onChanged: (gender) => setState(() => _gender = gender),
            ),
            second: AppLabeledDropdownField<HostLanguage>(
              label: AppStrings.motherTongueField,
              hint: AppStrings.selectHint,
              value: _motherTongue,
              options: HostLanguage.values,
              labelOf: HostProfileLabels.language,
              onChanged: (language) => setState(() => _motherTongue = language),
            ),
          ),
          const SizedBox(height: _rowGap),
          Text(
            AppStrings.speakLanguagesField,
            style: AppTextStyles.labelSmall.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: _labelGap),
          AppChoiceChips<HostLanguage>(
            options: HostLanguage.values,
            selected: _languages,
            labelOf: HostProfileLabels.language,
            onChanged: (languages) => setState(() => _languages = languages),
          ),
          if (_errorMessage case final message?) ...[
            const SizedBox(height: _rowGap),
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
