import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_choice_chips.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_field_row.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_labeled_dropdown_field.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_labeled_text_field.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/host_profile_options.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/widgets/host_profile_labels.dart';

class HostRequestEditForm extends StatelessWidget {
  const HostRequestEditForm({
    super.key,
    required this.realNameController,
    required this.nickNameController,
    required this.phoneController,
    required this.dateOfBirthController,
    required this.cityController,
    required this.gender,
    required this.languages,
    required this.onTextChanged,
    required this.onPickDateOfBirth,
    required this.onGenderChanged,
    required this.onLanguagesChanged,
  });

  static const double _rowGap = 14;
  static const double _labelGap = 7;

  final TextEditingController realNameController;
  final TextEditingController nickNameController;
  final TextEditingController phoneController;
  final TextEditingController dateOfBirthController;
  final TextEditingController cityController;
  final HostGender? gender;
  final Set<HostLanguage> languages;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onPickDateOfBirth;
  final ValueChanged<HostGender> onGenderChanged;
  final ValueChanged<Set<HostLanguage>> onLanguagesChanged;

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
      onChanged: onTextChanged,
      dense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFieldRow(
          first: _textField(AppStrings.realName, realNameController),
          second: _textField(AppStrings.nickName, nickNameController),
        ),
        const SizedBox(height: _rowGap),
        AppFieldRow(
          first: _textField(
            AppStrings.mobileNumber,
            phoneController,
            keyboardType: TextInputType.phone,
          ),
          second: AppLabeledTextField(
            label: AppStrings.dateOfBirth,
            hint: AppStrings.selectHint,
            controller: dateOfBirthController,
            readOnly: true,
            onTap: onPickDateOfBirth,
            dense: true,
          ),
        ),
        const SizedBox(height: _rowGap),
        AppFieldRow(
          first: _textField(AppStrings.city, cityController),
          second: AppLabeledDropdownField<HostGender>(
            label: AppStrings.gender,
            hint: AppStrings.selectHint,
            value: gender,
            options: HostGender.values,
            labelOf: HostProfileLabels.gender,
            onChanged: (value) {
              if (value != null) onGenderChanged(value);
            },
          ),
        ),
        const SizedBox(height: _rowGap),
        Text(
          AppStrings.speakLanguages,
          style: AppTextStyles.labelSmall.copyWith(
            color: context.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: _labelGap),
        AppChoiceChips<HostLanguage>(
          options: HostLanguage.values,
          selected: languages,
          labelOf: HostProfileLabels.language,
          onChanged: onLanguagesChanged,
        ),
      ],
    );
  }
}
