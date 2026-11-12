import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/enums/date_range_filter.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/features/calls/data/models/call_log.dart';

enum CallStatusFilter {
  incoming,
  completed(status: CallLogStatus.completed),
  busy(status: CallLogStatus.busy),
  rejected(status: CallLogStatus.rejected),
  notAnswered(status: CallLogStatus.missed),
  lowBalance(lowBalanceOnly: true),
  missed(status: CallLogStatus.cancelled);

  const CallStatusFilter({this.status, this.lowBalanceOnly = false});

  final CallLogStatus? status;
  final bool lowBalanceOnly;

  bool includes(CallLog call) {
    if (lowBalanceOnly) return call.isLowBalance;
    final value = status;
    return value == null || call.status == value;
  }
}

enum CallTypeOption {
  all,
  audio(type: CallLogType.audio),
  video(type: CallLogType.video);

  const CallTypeOption({this.type});

  final CallLogType? type;

  bool includes(CallLog call) {
    final value = type;
    return value == null || call.type == value;
  }
}

class CallsState {
  const CallsState({
    required this.today,
    this.calls = const [],
    this.status = LoadStatus.loading,
    this.errorMessage,
    this.query = '',
    this.dateFilter = DateRangeFilter.today,
    this.customRange,
    this.statusFilter = CallStatusFilter.incoming,
    this.typeFilter = CallTypeOption.all,
    this.page = 1,
    this.totalPages = 1,
    this.firstIndex = 0,
    this.totalCount,
    this.matchCount,
  });

  static const List<DateRangeFilter> dateOptions = [
    DateRangeFilter.today,
    DateRangeFilter.yesterday,
    DateRangeFilter.last7Days,
    DateRangeFilter.last30Days,
    DateRangeFilter.custom,
  ];

  static final RegExp _nonDigits = RegExp(r'\D');
  static final RegExp _phoneSeparators = RegExp(r'[\s+\-()]');

  final List<CallLog> calls;
  final LoadStatus status;
  final String? errorMessage;
  final DateTime today;
  final String query;
  final DateRangeFilter dateFilter;
  final DateTimeRange? customRange;
  final CallStatusFilter statusFilter;
  final CallTypeOption typeFilter;
  final int page;
  final int totalPages;
  final int firstIndex;
  final int? totalCount;
  final int? matchCount;

  bool get isSearching => query.trim().isNotEmpty;

  int? get shownCount => isSearching ? matchCount : totalCount;

  bool matchesSearch(CallLog call) =>
      statusFilter.includes(call) &&
      typeFilter.includes(call) &&
      _matchesQuery(call);

  bool _matchesQuery(CallLog call) {
    final term = query.trim().toLowerCase();
    if (term.isEmpty) return true;
    final texts = [
      call.userName,
      call.hostName,
      call.hostDisplayId,
      call.hostId,
      call.userDisplayId,
    ];
    if (texts.any((text) => text.toLowerCase().contains(term))) return true;

    final digits = term.replaceAll(_nonDigits, '');
    final phone = call.userPhone?.replaceAll(_nonDigits, '') ?? '';
    return digits.isNotEmpty &&
        digits.length == term.replaceAll(_phoneSeparators, '').length &&
        phone.contains(digits);
  }

  CallsState copyWith({
    List<CallLog>? calls,
    LoadStatus? status,
    String? errorMessage,
    DateTime? today,
    String? query,
    DateRangeFilter? dateFilter,
    DateTimeRange? customRange,
    CallStatusFilter? statusFilter,
    CallTypeOption? typeFilter,
    int? page,
    int? totalPages,
    int? firstIndex,
    int? totalCount,
    int? matchCount,
    bool clearTotalCount = false,
    bool clearMatchCount = false,
  }) {
    return CallsState(
      calls: calls ?? this.calls,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      today: today ?? this.today,
      query: query ?? this.query,
      dateFilter: dateFilter ?? this.dateFilter,
      customRange: customRange ?? this.customRange,
      statusFilter: statusFilter ?? this.statusFilter,
      typeFilter: typeFilter ?? this.typeFilter,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      firstIndex: firstIndex ?? this.firstIndex,
      totalCount: clearTotalCount ? null : totalCount ?? this.totalCount,
      matchCount: clearMatchCount ? null : matchCount ?? this.matchCount,
    );
  }
}
