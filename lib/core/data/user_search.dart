abstract final class UserSearch {
  static const String userNameField = 'userName';
  static const String hostUserNameField = 'hostDetails.userName';
  static const String userIDField = 'userID';
  static const String phoneNumberField = 'phoneNumber';
  static const String prefixEnd = '';
  static const int maxResultsPerPrefix = 100;
  static const int _nationalNumberLength = 10;

  static final RegExp _phoneLike = RegExp(r'^[+\d\s()-]+$');
  static final RegExp _whitespace = RegExp(r'\s+');
  static final RegExp _nonDigit = RegExp(r'\D');

  static String? normalizeTerm(String raw) {
    final term = raw.trim().replaceAll(_whitespace, ' ');
    return term.isEmpty ? null : term;
  }

  static List<(String field, String prefix)> prefixes(
    String term, {
    required bool isHost,
  }) {
    final nameField = isHost ? hostUserNameField : userNameField;
    return {
      (nameField, term.toLowerCase()),
      (nameField, term),
      if (!term.contains(' ')) (userIDField, term.toUpperCase()),
      for (final phone in _phoneNumbers(term)) (phoneNumberField, phone),
    }.toList();
  }

  static List<String> _phoneNumbers(String term) {
    if (!_phoneLike.hasMatch(term)) return const [];
    final digits = term.replaceAll(_nonDigit, '');
    if (digits.isEmpty) return const [];
    return {
      digits,
      if (digits.length > _nationalNumberLength)
        digits.substring(digits.length - _nationalNumberLength),
    }.toList();
  }
}
