import 'package:zuno_admin_dashboard/features/calls/data/models/call_log.dart';

enum CallDateFilter { today, yesterday }

enum CallPeriod { day, week, month }

enum CallStatusFilter {
  incoming,
  completed,
  busy,
  rejected,
  notAnswered,
  lowBalance,
  missed,
}

enum CallTypeOption { all, audio, video }

class CallsState {
  const CallsState({
    required this.calls,
    required this.today,
    this.query = '',
    this.date = CallDateFilter.today,
    this.period = CallPeriod.day,
    this.status = CallStatusFilter.incoming,
    this.type = CallTypeOption.all,
    this.page = 1,
  });

  static const int pageSize = 12;

  final List<CallLog> calls;
  final DateTime today;
  final String query;
  final CallDateFilter date;
  final CallPeriod period;
  final CallStatusFilter status;
  final CallTypeOption type;
  final int page;

  DateTime get _rangeEnd => switch (date) {
    CallDateFilter.today => today,
    CallDateFilter.yesterday => today.subtract(const Duration(days: 1)),
  };

  int get _periodDays => switch (period) {
    CallPeriod.day => 1,
    CallPeriod.week => 7,
    CallPeriod.month => 30,
  };

  bool _inRange(DateTime moment) {
    final day = DateTime(moment.year, moment.month, moment.day);
    final start = _rangeEnd.subtract(Duration(days: _periodDays - 1));
    return !day.isBefore(start) && !day.isAfter(_rangeEnd);
  }

  bool _matchesStatus(CallLogStatus value) => switch (status) {
    CallStatusFilter.incoming => true,
    CallStatusFilter.completed => value == CallLogStatus.completed,
    CallStatusFilter.busy => value == CallLogStatus.busy,
    CallStatusFilter.rejected => value == CallLogStatus.rejected,
    CallStatusFilter.notAnswered => value == CallLogStatus.notAnswered,
    CallStatusFilter.lowBalance => value == CallLogStatus.lowBalance,
    CallStatusFilter.missed => value == CallLogStatus.missed,
  };

  bool _matchesType(CallLogType value) => switch (type) {
    CallTypeOption.all => true,
    CallTypeOption.audio => value == CallLogType.audio,
    CallTypeOption.video => value == CallLogType.video,
  };

  bool _matchesQuery(CallLog call) {
    final term = query.trim().toLowerCase();
    if (term.isEmpty) return true;
    final digits = term.replaceAll(' ', '');
    return call.userName.toLowerCase().contains(term) ||
        call.userId.toLowerCase().contains(term) ||
        call.hostName.toLowerCase().contains(term) ||
        call.hostId.toLowerCase().contains(term) ||
        (digits.isNotEmpty &&
            call.userPhone.replaceAll(' ', '').contains(digits));
  }

  List<CallLog> get filteredCalls => calls
      .where(
        (call) =>
            _inRange(call.initiatedAt) &&
            _matchesStatus(call.status) &&
            _matchesType(call.type) &&
            _matchesQuery(call),
      )
      .toList();

  int get totalPages {
    final count = filteredCalls.length;
    if (count == 0) return 1;
    return (count / pageSize).ceil();
  }

  int get firstIndex => (page - 1) * pageSize;

  List<CallLog> get pageCalls =>
      filteredCalls.skip(firstIndex).take(pageSize).toList();

  CallsState copyWith({
    String? query,
    CallDateFilter? date,
    CallPeriod? period,
    CallStatusFilter? status,
    CallTypeOption? type,
    int? page,
  }) {
    return CallsState(
      calls: calls,
      today: today,
      query: query ?? this.query,
      date: date ?? this.date,
      period: period ?? this.period,
      status: status ?? this.status,
      type: type ?? this.type,
      page: page ?? this.page,
    );
  }
}
