abstract final class UserSearch {
  static const String userNameField = 'userName';
  static const String hostUserNameField = 'hostDetails.userName';
  static const String hostFullNameField = 'hostDetails.fullName';
  static const String userIDField = 'userID';
  static const String phoneNumberField = 'phoneNumber';
  static const String prefixEnd = '';
  static const int maxResultsPerPrefix = 100;
  static const int _nationalNumberLength = 10;

  /// Name fields searched on Approval, where a request can belong to a user
  /// who is not yet a host: the host nickname, the real name from the host
  /// application, and the account nickname.
  static const List<String> approvalNameFields = [
    hostUserNameField,
    hostFullNameField,
    userNameField,
  ];

  static final RegExp _phoneLike = RegExp(r'^[+\d\s()-]+$');
  static final RegExp _whitespace = RegExp(r'\s+');
  static final RegExp _nonDigit = RegExp(r'\D');
  static final RegExp _wordStart = RegExp(r'(^|\s)(\S)');

  static String? normalizeTerm(String raw, {int minLength = 1}) {
    final term = raw.trim().replaceAll(_whitespace, ' ');
    return term.length < minLength ? null : term;
  }

  static List<(String field, String prefix)> prefixes(
    String term, {
    required bool isHost,
  }) => prefixesFor(term, [isHost ? hostUserNameField : userNameField]);

  /// "Starts with" prefixes for [term] on each of [nameFields] (as typed,
  /// lowercase and capitalized), the user ID (uppercase) and, for phone-like
  /// text, the phone number digits with and without the country code.
  static List<(String field, String prefix)> prefixesFor(
    String term,
    List<String> nameFields,
  ) {
    final names = {term, term.toLowerCase(), _titleCase(term)};
    return {
      for (final field in nameFields)
        for (final name in names) (field, name),
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

  static String _titleCase(String term) => term.toLowerCase().replaceAllMapped(
    _wordStart,
    (match) => '${match[1]}${match[2]!.toUpperCase()}',
  );
}
