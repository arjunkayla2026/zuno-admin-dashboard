import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/record_page.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/features/reports/data/datasources/reports_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/reports/data/models/report_search.dart';
import 'package:zuno_admin_dashboard/features/reports/data/models/reports_query.dart';
import 'package:zuno_admin_dashboard/features/reports/data/models/user_report.dart';

class ReportsRepository {
  ReportsRepository(this._reports);

  static const int pageSize = 10;

  final ReportsRemoteDataSource _reports;
  final Map<String, ReportSearchResult> _searches = {};
  final Map<String, Future<Either<Failure, ReportSearchResult>>> _pending = {};

  Future<Either<Failure, RecordPage<UserReport>>> fetchPage(
    ReportsQuery query, {
    Object? cursor,
  }) async {
    final page = await _loadPage(query, cursor);
    return switch (page) {
      Left() => page,
      Right(value: final loaded) => right(await _withReceivedTotals(loaded)),
    };
  }

  Future<Either<Failure, int>> count(ReportsQuery query) async {
    final term = query.term;
    if (term == null) return _reports.count(query);
    final result = await _search(term);
    return result.map((found) => found.reports.where(query.includes).length);
  }

  Future<RecordPage<UserReport>> _withReceivedTotals(
    RecordPage<UserReport> page,
  ) async {
    final reportedIds = {
      for (final report in page.items)
        if (report.reported.id.isNotEmpty) report.reported.id,
    }.toList();
    if (reportedIds.isEmpty) return page;
    final result = await _reports.fetchReceivedTotals(reportedIds);
    final totals = result.getOrElse((_) => const {});
    return page.mapItems(
      (items) => [
        for (final report in items)
          report.withReceivedTotal(totals[report.reported.id]),
      ],
    );
  }

  Future<Either<Failure, RecordPage<UserReport>>> _loadPage(
    ReportsQuery query,
    Object? cursor,
  ) async {
    if (cursor case LocalPageCursor<UserReport>(:final remaining)) {
      return right(RecordPages.local(remaining, pageSize));
    }
    final term = query.term;
    if (term == null) {
      return _reports.fetchPage(query, cursor: cursor, pageSize: pageSize);
    }
    final result = await _search(term);
    return result.map(
      (found) => RecordPages.local(
        found.reports.where(query.includes).toList(),
        pageSize,
      ),
    );
  }

  Future<Either<Failure, ReportSearchResult>> _search(String term) async {
    if (_searches[term] case final cached?) return right(cached);

    for (final MapEntry(key: known, value: result) in _searches.entries) {
      if (result.isComplete && ReportSearch.covers(known, term)) {
        return right(
          _searches[term] = (
            reports: [
              for (final report in result.reports)
                if (ReportSearch.matches(report.searchValues, term)) report,
            ],
            isComplete: true,
          ),
        );
      }
    }

    final result = await (_pending[term] ??= _reports.search(term));
    _pending.remove(term);
    return result.map((found) => _searches[term] = found);
  }
}
