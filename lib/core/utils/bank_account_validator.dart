import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';

abstract final class BankAccountValidator {
  static const int nameMinLength = 3;
  static const int nameMaxLength = 50;
  static const int accountNumberMinLength = 9;
  static const int accountNumberMaxLength = 18;
  static const int ifscLength = 11;
  static const int panLength = 10;

  static final RegExp _holderNamePattern = RegExp(r"^[A-Za-z][A-Za-z .']*$");
  static final RegExp _branchNamePattern = RegExp(
    r"^[A-Za-z0-9][A-Za-z0-9 .,&()'\-/]*$",
  );
  static final RegExp _digitsPattern = RegExp(r'^\d+$');
  static final RegExp _ifscPattern = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
  static final RegExp _panPattern = RegExp(
    r'^[A-Z]{3}[ABCFGHJLPT][A-Z][0-9]{4}[A-Z]$',
  );
  static final RegExp _whitespace = RegExp(r'\s+');

  static String normalizeName(String? value) =>
      (value ?? '').trim().replaceAll(_whitespace, ' ');

  static String normalizeAccountNumber(String? value) =>
      (value ?? '').replaceAll(_whitespace, '');

  static String normalizeIfsc(String? value) => _code(value);

  static String normalizePan(String? value) => _code(value);

  static String _code(String? value) =>
      (value ?? '').replaceAll(_whitespace, '').toUpperCase();

  static bool _hasNameLength(String value) =>
      value.length >= nameMinLength && value.length <= nameMaxLength;

  static String? accountHolderName(String? value) {
    final name = normalizeName(value);
    if (name.isEmpty) return AppStrings.holderNameRequired;
    if (!_holderNamePattern.hasMatch(name)) {
      return AppStrings.holderNameInvalid;
    }
    return _hasNameLength(name) ? null : AppStrings.holderNameLength;
  }

  static String? branchName(String? value) {
    final branch = normalizeName(value);
    if (branch.isEmpty) return AppStrings.branchNameRequired;
    if (!_branchNamePattern.hasMatch(branch)) {
      return AppStrings.branchNameInvalid;
    }
    return _hasNameLength(branch) ? null : AppStrings.branchNameLength;
  }

  static String? accountNumber(String? value) {
    final number = normalizeAccountNumber(value);
    if (number.isEmpty) return AppStrings.accountNumberRequired;
    if (!_digitsPattern.hasMatch(number)) {
      return AppStrings.accountNumberInvalid;
    }
    final hasLength =
        number.length >= accountNumberMinLength &&
        number.length <= accountNumberMaxLength;
    return hasLength ? null : AppStrings.accountNumberLength;
  }

  static String? ifscCode(String? value) {
    final code = normalizeIfsc(value);
    if (code.isEmpty) return AppStrings.ifscRequired;
    if (code.length != ifscLength) return AppStrings.ifscLength;
    return _ifscPattern.hasMatch(code) ? null : AppStrings.ifscInvalid;
  }

  static String? panNumber(String? value, {bool required = true}) {
    final pan = normalizePan(value);
    if (pan.isEmpty) return required ? AppStrings.panRequired : null;
    if (pan.length != panLength) return AppStrings.panLength;
    return _panPattern.hasMatch(pan) ? null : AppStrings.panInvalid;
  }
}
