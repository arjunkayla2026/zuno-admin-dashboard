import 'package:zuno_admin_dashboard/core/data/user_search.dart';
import 'package:zuno_admin_dashboard/features/reports/data/models/user_report.dart';

abstract final class ReportSearch {
  static const int maxResultsPerPrefix = 50;
  static const String reportedByNameField = UserReport.reportedByNameField;
  static const String reportedNameField = UserReport.reportedNameField;
  static const String customerUserIdField = UserReport.customerUserIdField;
  static const String hostUserIdField = UserReport.hostUserIdField;
  static const String reportedByPhoneField = UserReport.reportedByPhoneField;
  static const String reportedPhoneField = UserReport.reportedPhoneField;

  static const List<String> fields = [
    reportedByNameField,
    reportedNameField,
    customerUserIdField,
    hostUserIdField,
    reportedByPhoneField,
    reportedPhoneField,
  ];

  static const String _defaultCountryCode = '+91';
  static const int _nationalNumberLength = 10;

  static final RegExp _phoneLike = RegExp(r'^[+\d\s()-]+$');
  static final RegExp _nonDigit = RegExp(r'\D');
  static final RegExp _wordStart = RegExp(r'(^|\s)(\S)');

  static const int minTermLength = 2;

  static String? normalizeTerm(String raw) {
    final term = UserSearch.normalizeTerm(raw);
    return term == null || term.length < minTermLength ? null : term;
  }

  static List<(String field, String prefix)> prefixes(String term) {
    if (_phoneLike.hasMatch(term)) {
      final digits = term.replaceAll(_nonDigit, '');
      if (digits.isEmpty) return const [];
      final phones = {
        digits,
        '+$digits',
        if (digits.length <= _nationalNumberLength)
          '$_defaultCountryCode$digits',
      };
      return [
        for (final field in const [reportedByPhoneField, reportedPhoneField])
          for (final phone in phones) (field, phone),
      ];
    }

    final names = {term, term.toLowerCase(), _titleCase(term)};
    return [
      for (final field in const [reportedByNameField, reportedNameField])
        for (final name in names) (field, name),
      if (!term.contains(' ')) ...[
        (customerUserIdField, term.toUpperCase()),
        (hostUserIdField, term.toUpperCase()),
      ],
    ];
  }

  static bool covers(String broader, String narrower) {
    final known = prefixes(broader);
    return prefixes(narrower).every(
      (pair) => known.any(
        (candidate) =>
            candidate.$1 == pair.$1 && pair.$2.startsWith(candidate.$2),
      ),
    );
  }

  static bool matches(Map<String, String> values, String term) =>
      prefixes(term)
          .any((pair) => values[pair.$1]?.startsWith(pair.$2) ?? false);

  static String _titleCase(String term) => term.toLowerCase().replaceAllMapped(
    _wordStart,
    (match) => '${match[1]}${match[2]!.toUpperCase()}',
  );
}
