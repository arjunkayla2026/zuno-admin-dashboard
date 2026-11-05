abstract final class NumberFormatter {
  static const String _rupee = '₹';

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

  static int parse(String value) =>
      int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
}
