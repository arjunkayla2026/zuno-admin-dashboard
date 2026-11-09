abstract final class NameFormatter {
  static String initials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    final first = words.first;
    if (first.isEmpty) return '';
    final last = words.length > 1 ? words.last : '';
    return (first[0] + (last.isEmpty ? '' : last[0])).toUpperCase();
  }
}
