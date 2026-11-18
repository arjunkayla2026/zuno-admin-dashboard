import 'package:flutter/services.dart';

class VersionInputFormatter extends TextInputFormatter {
  VersionInputFormatter();

  static final RegExp complete = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}$');

  static final RegExp _partial = RegExp(
    r'^(\d{1,3}(\.(\d{1,3}(\.\d{0,3})?)?)?)?$',
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => _partial.hasMatch(newValue.text) ? newValue : oldValue;
}
