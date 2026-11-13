import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/enums/date_range_filter.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/utils/date_range_matcher.dart';
import 'package:zuno_admin_dashboard/features/reports/data/models/report_search.dart';
import 'package:zuno_admin_dashboard/features/reports/data/models/reports_query.dart';
import 'package:zuno_admin_dashboard/features/reports/data/models/user_report.dart';

enum ReportTypeFilter {
  all,
  askingPersonalDetails(ReportType.askingPersonalDetails),
  offensiveLanguage(ReportType.offensiveLanguage),
  inappropriateBehavior(ReportType.inappropriateBehavior),
  requestingPersonalDetails(ReportType.requestingPersonalDetails),
  notResponding(ReportType.notResponding),
  moneyRequests(ReportType.moneyRequests),
  other(ReportType.other);

  const ReportTypeFilter([this.type]);

  final ReportType? type;
}

enum ReporterFilter {
  all,
  user(ReportPartyRole.user),
  host(ReportPartyRole.host);

  const ReporterFilter([this.role]);

  final ReportPartyRole? role;
}

class ReportsState {
  const ReportsState({
    required this.today,
    this.reports = const [],
    this.status = LoadStatus.loading,
    this.errorMessage,
    this.query = '',
    this.dateFilter = DateRangeFilter.all,
    this.customRange,
    this.typeFilter = ReportTypeFilter.all,
    this.reporterFilter = ReporterFilter.all,
    this.page = 1,
    this.totalPages = 1,
    this.firstIndex = 0,
    this.totalCount,
  });

  final List<UserReport> reports;
  final LoadStatus status;
  final String? errorMessage;
  final DateTime today;
  final String query;
  final DateRangeFilter dateFilter;
  final DateTimeRange? customRange;
  final ReportTypeFilter typeFilter;
  final ReporterFilter reporterFilter;
  final int page;
  final int totalPages;
  final int firstIndex;
  final int? totalCount;

  ReportsQuery get reportsQuery {
    final (from, until) = dateFilter.momentBounds(
      today: today,
      customRange: customRange,
    );
    return ReportsQuery(
      term: ReportSearch.normalizeTerm(query),
      from: from,
      until: until,
      type: typeFilter.type,
      reporterRole: reporterFilter.role,
    );
  }

  ReportsState copyWith({
    List<UserReport>? reports,
    LoadStatus? status,
    String? errorMessage,
    DateTime? today,
    String? query,
    DateRangeFilter? dateFilter,
    DateTimeRange? customRange,
    ReportTypeFilter? typeFilter,
    ReporterFilter? reporterFilter,
    int? page,
    int? totalPages,
    int? firstIndex,
    int? totalCount,
    bool clearTotalCount = false,
  }) {
    return ReportsState(
      reports: reports ?? this.reports,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      today: today ?? this.today,
      query: query ?? this.query,
      dateFilter: dateFilter ?? this.dateFilter,
      customRange: customRange ?? this.customRange,
      typeFilter: typeFilter ?? this.typeFilter,
      reporterFilter: reporterFilter ?? this.reporterFilter,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      firstIndex: firstIndex ?? this.firstIndex,
      totalCount: clearTotalCount ? null : totalCount ?? this.totalCount,
    );
  }
}
