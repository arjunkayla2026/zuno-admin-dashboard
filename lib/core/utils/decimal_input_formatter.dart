import 'package:flutter/services.dart';

class DecimalInputFormatter extends TextInputFormatter {
  DecimalInputFormatter({this.decimalDigits = 2, this.max})
    : _pattern = RegExp(
        r'^\d*\.?\d{0,'
        '$decimalDigits'
        r'}$',
      );

  final int decimalDigits;
  final double? max;
  final RegExp _pattern;

  bool _isWithinMax(String text) {
    final limit = max;
    if (limit == null) return true;
    final value = double.tryParse(text);
    return value == null || value <= limit;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => _pattern.hasMatch(newValue.text) && _isWithinMax(newValue.text)
      ? newValue
      : oldValue;
}
