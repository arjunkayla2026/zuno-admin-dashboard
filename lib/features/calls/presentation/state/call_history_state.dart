import 'package:zuno_admin_dashboard/core/enums/call_filter.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/features/calls/data/models/call_log.dart';

class CallHistoryState {
  const CallHistoryState({
    required this.singleDate,
    required this.rangeStart,
    required this.rangeEnd,
    this.calls = const [],
    this.status = LoadStatus.loading,
    this.errorMessage,
    this.typeFilter = CallTypeFilter.all,
    this.dateMode = CallDateMode.range,
    this.page = 1,
    this.totalPages = 1,
    this.firstIndex = 0,
    this.matchCount,
    this.totalCount,
  });

  factory CallHistoryState.startingOn(DateTime today) => CallHistoryState(
    singleDate: today,
    rangeStart: DateTime(today.year, today.month, today.day - 1),
    rangeEnd: today,
  );

  final List<CallLog> calls;
  final LoadStatus status;
  final String? errorMessage;
  final DateTime singleDate;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final CallTypeFilter typeFilter;
  final CallDateMode dateMode;
  final int page;
  final int totalPages;
  final int firstIndex;
  final int? matchCount;
  final int? totalCount;

  CallLogType? get callType => switch (typeFilter) {
    CallTypeFilter.all => null,
    CallTypeFilter.audio => CallLogType.audio,
    CallTypeFilter.video => CallLogType.video,
  };

  (DateTime, DateTime) get bounds {
    final (first, last) = switch (dateMode) {
      CallDateMode.single => (singleDate, singleDate),
      CallDateMode.range => (rangeStart, rangeEnd),
    };
    return (first, DateTime(last.year, last.month, last.day + 1));
  }

  CallHistoryState copyWith({
    List<CallLog>? calls,
    LoadStatus? status,
    String? errorMessage,
    DateTime? singleDate,
    DateTime? rangeStart,
    DateTime? rangeEnd,
    CallTypeFilter? typeFilter,
    CallDateMode? dateMode,
    int? page,
    int? totalPages,
    int? firstIndex,
    int? matchCount,
    int? totalCount,
    bool clearMatchCount = false,
  }) {
    return CallHistoryState(
      calls: calls ?? this.calls,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      singleDate: singleDate ?? this.singleDate,
      rangeStart: rangeStart ?? this.rangeStart,
      rangeEnd: rangeEnd ?? this.rangeEnd,
      typeFilter: typeFilter ?? this.typeFilter,
      dateMode: dateMode ?? this.dateMode,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      firstIndex: firstIndex ?? this.firstIndex,
      matchCount: clearMatchCount ? null : matchCount ?? this.matchCount,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}
