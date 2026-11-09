abstract final class NumberFormatter {
  static const String _rupee = '₹';
  static const int _amountDigits = 2;
  static const int _centsPerUnit = 100;

  static String grouped(int value) {
    final digits = value.abs().toString();
    final sign = value < 0 ? '-' : '';
    if (digits.length <= 3) return '$sign$digits';

    final lastThree = digits.substring(digits.length - 3);
    final leading = digits.substring(0, digits.length - 3);
    final parts = <String>[];
    for (var end = leading.length; end > 0; end -= 2) {
      parts.insert(0, leading.substring(end - 2 < 0 ? 0 : end - 2, end));
    }
    return '$sign${parts.join(',')},$lastThree';
  }

  static String rupees(int value) => '$_rupee${grouped(value)}';

  static String rupeesDecimal(double value) {
    final whole = value.truncate();
    if (whole == value) return rupees(whole);
    final fraction = value.toStringAsFixed(1).split('.').last;
    return '${rupees(whole)}.$fraction';
  }

  static String rupeesPaise(int paise) {
    const paisePerRupee = 100;
    final rupeesPart = rupees(paise ~/ paisePerRupee);
    final remainder = paise.abs() % paisePerRupee;
    if (remainder == 0) return rupeesPart;
    final fraction = remainder.toString().padLeft(2, '0');
    final trimmed = fraction.endsWith('0') ? fraction[0] : fraction;
    return '$rupeesPart.$trimmed';
  }

  static double roundAmount(double value) =>
      (value * _centsPerUnit).roundToDouble() / _centsPerUnit;

  static String amountInput(double value) =>
      roundAmount(value).toStringAsFixed(_amountDigits);

  static double? tryParseAmount(String value) {
    final text = value.trim();
    if (text.isEmpty || text == '.') return null;
    final parsed = double.tryParse(text.endsWith('.') ? '${text}0' : text);
    return parsed == null ? null : roundAmount(parsed);
  }

  static String groupedAmount(double value) {
    final cents = (value.abs() * _centsPerUnit).round();
    final sign = value < 0 && cents > 0 ? '-' : '';
    final whole = grouped(cents ~/ _centsPerUnit);
    final fraction = (cents % _centsPerUnit).toString().padLeft(
      _amountDigits,
      '0',
    );
    return '$sign$whole.$fraction';
  }

  static String rupeesAmount(double value) => '$_rupee${groupedAmount(value)}';

  static String trimmedAmount(double value) =>
      amountInput(value).replaceFirst(RegExp(r'\.?0+$'), '');

  static int parse(String value) =>
      int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
}
