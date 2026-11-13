import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/data_action.dart';
import 'package:zuno_admin_dashboard/core/data/record_page.dart';
import 'package:zuno_admin_dashboard/core/data/user_search.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/features/reports/data/models/report_search.dart';
import 'package:zuno_admin_dashboard/features/reports/data/models/reports_query.dart';
import 'package:zuno_admin_dashboard/features/reports/data/models/user_report.dart';

typedef ReportSearchResult = ({List<UserReport> reports, bool isComplete});

class ReportsRemoteDataSource {
  const ReportsRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _reports =>
      _firestore.collection(UserReport.collection);

  Query<Map<String, dynamic>> _filtered(ReportsQuery filter) {
    Query<Map<String, dynamic>> query = _reports;
    if (filter.type case final type?) {
      query = query.where(UserReport.reportTypeField, isEqualTo: type.value);
    }
    if (filter.reporterRole case final role?) {
      query = query.where(UserReport.reporterRoleField, isEqualTo: role.value);
    }
    return query;
  }

  Future<Either<Failure, RecordPage<UserReport>>> fetchPage(
    ReportsQuery filter, {
    Object? cursor,
    required int pageSize,
  }) => DataAction.guard(
    'reports.fetchPage',
    () => RecordPages.fetch(
      _filtered(filter),
      RecordPageQuery(from: filter.from, until: filter.until, cursor: cursor),
      UserReport.fromDocument,
      sortField: UserReport.reportedAtField,
      pageSize: pageSize,
    ),
  );

  Future<Either<Failure, int>> count(ReportsQuery filter) =>
      DataAction.read('reports.count', () async {
        var query = _filtered(filter);
        if (filter.from case final from?) {
          query = query.where(
            UserReport.reportedAtField,
            isGreaterThanOrEqualTo: Timestamp.fromDate(from),
          );
        }
        if (filter.until case final until?) {
          query = query.where(
            UserReport.reportedAtField,
            isLessThan: Timestamp.fromDate(until),
          );
        }
        final snapshot = await query.count().get();
        return snapshot.count ?? 0;
      });

  Future<Either<Failure, Map<String, int>>> fetchReceivedTotals(
    List<String> reportedIds,
  ) => DataAction.read('reports.fetchReceivedTotals', () async {
    final snapshot = await _firestore
        .collection(UserReport.reportedUsersCollection)
        .where(FieldPath.documentId, whereIn: reportedIds)
        .get();
    return {
      for (final document in snapshot.docs)
        if (document.data()[UserReport.totalReceivedCountField]
            case final num total)
          document.id: total.round(),
    };
  });

  Future<Either<Failure, ReportSearchResult>> search(String term) =>
      DataAction.read('reports.search', () async {
        final snapshots = await Future.wait([
          for (final (field, prefix) in ReportSearch.prefixes(term))
            _reports
                .where(field, isGreaterThanOrEqualTo: prefix)
                .where(field, isLessThan: '$prefix${UserSearch.prefixEnd}')
                .orderBy(field)
                .limit(ReportSearch.maxResultsPerPrefix)
                .get(),
        ]);
        final reports = <String, UserReport>{
          for (final snapshot in snapshots)
            for (final document in snapshot.docs)
              document.id: UserReport.fromDocument(
                document.id,
                document.data(),
              ),
        }.values.toList()..sort((a, b) => b.date.compareTo(a.date));
        return (
          reports: reports,
          isComplete: snapshots.every(
            (snapshot) => snapshot.size < ReportSearch.maxResultsPerPrefix,
          ),
        );
      });
}
