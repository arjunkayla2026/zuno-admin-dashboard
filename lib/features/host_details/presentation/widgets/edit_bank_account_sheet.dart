import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/bank_account_validator.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_error_banner.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_field_row.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_labeled_text_field.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_profile_header.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_side_sheet.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/bank_account_record.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/admin_host.dart';

class EditBankAccountSheet extends StatefulWidget {
  const EditBankAccountSheet({
    super.key,
    required this.host,
    required this.account,
    required this.onSave,
  });

  final AdminHost host;
  final BankAccountRecord account;
  final Future<String?> Function(BankAccountRecord edited) onSave;

  @override
  State<EditBankAccountSheet> createState() => _EditBankAccountSheetState();
}

class _EditBankAccountSheetState extends State<EditBankAccountSheet> {
  static const double _profileGap = 21;
  static const double _rowGap = 14;
  static const double _footerGap = 10;
  static const double _loaderSize = 16;
  static const double _loaderStroke = 2;
  static final RegExp _codeCharacter = RegExp('[A-Za-z0-9]');
  static final TextInputFormatter _upperCase = TextInputFormatter.withFunction(
    (_, value) => value.copyWith(text: value.text.toUpperCase()),
  );

  late final _holderNameController = TextEditingController(
    text: widget.account.accountHolderName ?? '',
  );
  late final _branchNameController = TextEditingController(
    text: widget.account.branchName ?? '',
  );
  late final _accountNumberController = TextEditingController(
    text: widget.account.accountNumber ?? '',
  );
  late final _ifscController = TextEditingController(
    text: widget.account.ifscCode ?? '',
  );
  late final _panController = TextEditingController(
    text: widget.account.panNumber ?? '',
  );

  bool _submitted = false;
  bool _saving = false;
  String? _errorMessage;

  List<TextEditingController> get _controllers => [
    _holderNameController,
    _branchNameController,
    _accountNumberController,
    _ifscController,
    _panController,
  ];

  BankAccountRecord get _edited => widget.account.copyWith(
    accountHolderName: BankAccountValidator.normalizeName(
      _holderNameController.text,
    ),
    branchName: BankAccountValidator.normalizeName(_branchNameController.text),
    accountNumber: BankAccountValidator.normalizeAccountNumber(
      _accountNumberController.text,
    ),
    ifscCode: BankAccountValidator.normalizeIfsc(_ifscController.text),
    panNumber: BankAccountValidator.normalizePan(_panController.text),
  );

  String? get _holderNameError =>
      BankAccountValidator.accountHolderName(_holderNameController.text);

  String? get _branchNameError =>
      BankAccountValidator.branchName(_branchNameController.text);

  String? get _accountNumberError =>
      BankAccountValidator.accountNumber(_accountNumberController.text);

  String? get _ifscError => BankAccountValidator.ifscCode(_ifscController.text);

  String? get _panError => BankAccountValidator.panNumber(
    _panController.text,
    required: widget.account.panNumber != null,
  );

  bool get _isValid => [
    _holderNameError,
    _branchNameError,
    _accountNumberError,
    _ifscError,
    _panError,
  ].every((error) => error == null);

  bool get _hasChanges => !_edited.hasSameDetails(widget.account);

  void _onChanged(String _) => setState(() {});

  Future<void> _save() async {
    if (_saving || !_hasChanges) return;
    if (!_isValid) {
      setState(() => _submitted = true);
      return;
    }
    setState(() {
      _submitted = true;
      _saving = true;
      _errorMessage = null;
    });

    final error = await widget.onSave(_edited);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _saving = false;
      _errorMessage = error;
    });
  }

  Widget _field(
    String label,
    String hint,
    TextEditingController controller, {
    required String? error,
    required List<TextInputFormatter> inputFormatters,
    TextInputType? keyboardType,
    bool last = false,
  }) {
    return AppLabeledTextField(
      label: label,
      hint: hint,
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: last ? TextInputAction.done : TextInputAction.next,
      inputFormatters: inputFormatters,
      errorText: _submitted ? error : null,
      readOnly: _saving,
      onChanged: _onChanged,
      onSubmitted: last ? (_) => _save() : null,
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
    final updatedAt = widget.account.updatedAt;

    return AppSideSheet(
      title: AppStrings.editBankAccount,
      subtitle: AppStrings.bankAccountSubtitle(
        host.userID,
        updatedAt == null ? null : DateFormatter.short(updatedAt),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppProfileHeader(
            initials: host.initials,
            avatarIndex: host.avatarIndex,
            name: host.name,
            subtitle: host.userID,
            imageUrl: host.profileImageUrl,
          ),
          const SizedBox(height: _profileGap),
          AppFieldRow(
            first: _field(
              AppStrings.accountHolderNameField,
              AppStrings.holderNameHint,
              _holderNameController,
              error: _holderNameError,
              keyboardType: TextInputType.name,
              inputFormatters: [
                LengthLimitingTextInputFormatter(
                  BankAccountValidator.nameMaxLength,
                ),
              ],
            ),
            second: _field(
              AppStrings.branchName,
              AppStrings.branchNameHint,
              _branchNameController,
              error: _branchNameError,
              inputFormatters: [
                LengthLimitingTextInputFormatter(
                  BankAccountValidator.nameMaxLength,
                ),
              ],
            ),
          ),
          const SizedBox(height: _rowGap),
          AppFieldRow(
            first: _field(
              AppStrings.accountNumber,
              AppStrings.accountNumberHint,
              _accountNumberController,
              error: _accountNumberError,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(
                  BankAccountValidator.accountNumberMaxLength,
                ),
              ],
            ),
            second: _field(
              AppStrings.ifscCode,
              AppStrings.ifscHint,
              _ifscController,
              error: _ifscError,
              keyboardType: TextInputType.text,
              inputFormatters: [
                FilteringTextInputFormatter.allow(_codeCharacter),
                _upperCase,
                LengthLimitingTextInputFormatter(
                  BankAccountValidator.ifscLength,
                ),
              ],
            ),
          ),
          const SizedBox(height: _rowGap),
          AppFieldRow(
            first: _field(
              AppStrings.panNumber,
              AppStrings.panHint,
              _panController,
              error: _panError,
              keyboardType: TextInputType.text,
              inputFormatters: [
                FilteringTextInputFormatter.allow(_codeCharacter),
                _upperCase,
                LengthLimitingTextInputFormatter(
                  BankAccountValidator.panLength,
                ),
              ],
              last: true,
            ),
            second: const SizedBox.shrink(),
          ),
          const SizedBox(height: _rowGap),
          Text(
            AppStrings.bankAccountEditNote,
            style: AppTextStyles.bodySmall.copyWith(
              color: context.appColors.textSecondary,
            ),
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
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (_saving)
            SizedBox.square(
              dimension: _loaderSize,
              child: CircularProgressIndicator(
                strokeWidth: _loaderStroke,
                color: context.appColors.onPrimarySoft,
              ),
            ),
          AppSecondaryButton(
            label: AppStrings.cancel,
            onPressed: _saving ? null : () => Navigator.of(context).pop(),
          ),
          AppPrimaryButton(
            label: _saving ? AppStrings.saving : AppStrings.saveChanges,
            compact: true,
            onPressed: _hasChanges && !_saving ? _save : null,
          ),
        ],
      ),
    );
  }
}
