abstract final class SearchKeywords {
  static const String field = 'searchKeywords';
  static const String bankAccountsCollection = 'bankAccounts';
  static const String bankDetailsCollection = 'bankDetails';
  static const int minTermLength = 2;
  static const int _maxLength = 24;
  static const Set<String> _searchableFields = {
    'name',
    'userName',
    'userID',
    'phoneNumber',
    'countryCode',
    'hostDetails.userName',
    'hostDetails.fullName',
    'hostDetails.district',
    'hostDetails.state',
  };

  static final RegExp _phoneLike = RegExp(r'^[+\d\s()-]+$');
  static final RegExp _whitespace = RegExp(r'\s+');
  static final RegExp _nonDigit = RegExp(r'\D');

  static String? normalizeTerm(String raw) {
    final trimmed = raw.trim();
    final normalized = _phoneLike.hasMatch(trimmed)
        ? trimmed.replaceAll(_nonDigit, '')
        : _normalizeText(trimmed);
    if (normalized.length < minTermLength) return null;
    return normalized.length > _maxLength
        ? normalized.substring(0, _maxLength)
        : normalized;
  }

  static List<String> build({
    required Iterable<Object?> texts,
    required Iterable<Object?> phones,
  }) {
    final keywords = <String>{};
    for (final text in texts.whereType<String>()) {
      final normalized = _normalizeText(text);
      if (normalized.isEmpty) continue;
      keywords.addAll(_prefixes(normalized));
      for (final word in normalized.split(' ')) {
        keywords.addAll(_prefixes(word));
      }
    }
    for (final phone in phones.whereType<String>()) {
      keywords.addAll(_prefixes(phone.replaceAll(_nonDigit, '')));
    }
    return keywords.toList()..sort();
  }

  static List<String> forUser(Map<String, dynamic> user) {
    final details = user['hostDetails'];
    final hostDetails = details is Map ? details : const {};
    return build(texts: _userTexts(user, hostDetails), phones: _phones(user));
  }

  static List<String> forBankAccount(
    Map<String, dynamic> account,
    Map<String, dynamic>? user,
  ) {
    final details = user?['hostDetails'];
    final hostDetails = details is Map ? details : const {};
    return build(
      texts: [
        account['accountHolderName'],
        if (user != null) ..._userTexts(user, hostDetails),
      ],
      phones: user == null ? const [] : _phones(user),
    );
  }

  static bool touchesSearchableField(Map<String, Object?> fields) =>
      fields.keys.any(_searchableFields.contains);

  static Map<String, dynamic> withUpdates(
    Map<String, dynamic> data,
    Map<String, Object?> fields,
  ) {
    final merged = {...data};
    for (final MapEntry(:key, :value) in fields.entries) {
      final separator = key.indexOf('.');
      if (separator < 0) {
        merged[key] = value;
        continue;
      }
      final parent = key.substring(0, separator);
      final current = merged[parent];
      merged[parent] = {
        if (current is Map) ...current,
        key.substring(separator + 1): value,
      };
    }
    return merged;
  }

  static List<Object?> _userTexts(Map<String, dynamic> user, Map details) => [
    user['name'],
    user['userName'],
    user['userID'],
    details['userName'],
    details['fullName'],
    details['district'],
    details['state'],
  ];

  static List<Object?> _phones(Map<String, dynamic> user) {
    final number = user['phoneNumber'];
    final code = user['countryCode'];
    return [number, if (number is String && code is String) '$code$number'];
  }

  static String _normalizeText(String value) =>
      value.trim().toLowerCase().replaceAll(_whitespace, ' ');

  static Iterable<String> _prefixes(String value) sync* {
    final longest = value.length < _maxLength ? value.length : _maxLength;
    for (var length = minTermLength; length <= longest; length++) {
      yield value.substring(0, length);
    }
  }
}
