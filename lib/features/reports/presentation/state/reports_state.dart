import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/enums/date_range_filter.dart';
import 'package:zuno_admin_dashboard/core/utils/date_range_matcher.dart';
import 'package:zuno_admin_dashboard/features/reports/data/models/user_report.dart';

enum ReportTypeFilter { all, fakeProfile, harassment, abusiveLanguage, other }

enum ReporterFilter { all, user, host }

class ReportsState {
  const ReportsState({
    required this.reports,
    required this.today,
    this.query = '',
    this.dateFilter = DateRangeFilter.all,
    this.customRange,
    this.typeFilter = ReportTypeFilter.all,
    this.reporterFilter = ReporterFilter.all,
    this.page = 1,
  });

  static const int pageSize = 12;

  final List<UserReport> reports;
  final DateTime today;
  final String query;
  final DateRangeFilter dateFilter;
  final DateTimeRange? customRange;
  final ReportTypeFilter typeFilter;
  final ReporterFilter reporterFilter;
  final int page;

  bool _matchesType(ReportType type) => switch (typeFilter) {
    ReportTypeFilter.all => true,
    ReportTypeFilter.fakeProfile => type == ReportType.fakeProfile,
    ReportTypeFilter.harassment => type == ReportType.harassment,
    ReportTypeFilter.abusiveLanguage => type == ReportType.abusiveLanguage,
    ReportTypeFilter.other => type == ReportType.other,
  };

  bool _matchesReporter(ReportPartyRole role) => switch (reporterFilter) {
    ReporterFilter.all => true,
    ReporterFilter.user => role == ReportPartyRole.user,
    ReporterFilter.host => role == ReportPartyRole.host,
  };

  bool _matchesQuery(UserReport report) {
    final term = query.trim().toLowerCase();
    if (term.isEmpty) return true;
    return [
      report.reportedBy.name,
      report.reportedBy.id,
      report.reported.name,
      report.reported.id,
    ].any((text) => text.toLowerCase().contains(term));
  }

  List<UserReport> get filteredReports => reports
      .where(
        (report) =>
            dateFilter.includes(
              report.date,
              today: today,
              customRange: customRange,
            ) &&
            _matchesType(report.type) &&
            _matchesReporter(report.reportedBy.role) &&
            _matchesQuery(report),
      )
      .toList();

  int get totalPages {
    final count = filteredReports.length;
    if (count == 0) return 1;
    return (count / pageSize).ceil();
  }

  int get firstIndex => (page - 1) * pageSize;

  List<UserReport> get pageReports =>
      filteredReports.skip(firstIndex).take(pageSize).toList();

  ReportsState copyWith({
    String? query,
    DateRangeFilter? dateFilter,
    DateTimeRange? customRange,
    ReportTypeFilter? typeFilter,
    ReporterFilter? reporterFilter,
    int? page,
  }) {
    return ReportsState(
      reports: reports,
      today: today,
      query: query ?? this.query,
      dateFilter: dateFilter ?? this.dateFilter,
      customRange: customRange ?? this.customRange,
      typeFilter: typeFilter ?? this.typeFilter,
      reporterFilter: reporterFilter ?? this.reporterFilter,
      page: page ?? this.page,
    );
  }
}
