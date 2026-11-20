import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';

enum CallLogType {
  audio('audio'),
  video('video');

  const CallLogType(this.value);

  final String value;

  static CallLogType fromValue(Object? value) =>
      value == video.value ? video : audio;
}

enum CallLogStatus {
  ringing('ringing'),
  ongoing('ongoing'),
  completed('completed'),
  rejected('rejected'),
  cancelled('cancelled'),
  missed('missed'),
  failed('failed'),
  busy('busy');

  const CallLogStatus(this.value);

  static const String _acceptedValue = 'accepted';

  /// Raw status values of calls the host picked up.
  static const List<String> answeredValues = [
    'completed',
    'ongoing',
    _acceptedValue,
  ];

  final String value;

  /// The stored values this status stands for in a Firestore filter:
  /// `ongoing` also covers `accepted`, which [fromValue] reads as ongoing.
  List<String> get rawValues =>
      this == ongoing ? const [_acceptedValue, 'ongoing'] : [value];

  static CallLogStatus fromValue(Object? value) {
    final text = value is String ? value.trim().toLowerCase() : null;
    if (text == _acceptedValue) return ongoing;
    for (final status in values) {
      if (status.value == text) return status;
    }
    return failed;
  }
}

enum CallEndedBy {
  user('customer'),
  host('host'),
  system('system');

  const CallEndedBy(this.value);

  final String value;

  /// Reads the stored role. Besides the Cloud Functions values (`customer`,
  /// `host`, `system`) it accepts the older client spellings and any case.
  static CallEndedBy? fromValue(Object? value) {
    if (value is! String) return null;
    return switch (value.trim().toLowerCase()) {
      'customer' || 'user' || 'caller' => user,
      'host' || 'receiver' => host,
      'system' => system,
      _ => null,
    };
  }
}

class CallLog {
  const CallLog({
    required this.callId,
    required this.customerId,
    required this.hostId,
    required this.userName,
    required this.hostName,
    required this.type,
    required this.status,
    required this.initiatedAt,
    this.customerUserId,
    this.hostUserId,
    this.startedAt,
    this.endedAt,
    this.recordedDurationSeconds,
    this.endedBy,
    this.endReason,
    this.spendCoins = 0,
    this.spendRupees = 0,
    this.hostEarnings = 0,
    this.adminRevenue = 0,
    this.coinsPerSecond = _defaultCoinsPerSecond,
    this.coinsPerRupee = _defaultCoinsPerRupee,
    this.hostRatePerMinute = _defaultHostRupeesPerMinute,
    this.storedAdminRatePerMinute,
    this.isLowBalance = false,
    this.userPhone,
    this._channelId,
  });

  /// Reads a `calls` document. Each value is read from the key the calling
  /// app's Cloud Functions write today and falls back to the key older
  /// documents still carry (see the calling app's `docs/CALL_FLOW.md`,
  /// "Removed duplicate keys"), so documents that were never cleaned up
  /// still show their times, duration, money and who ended the call.
  factory CallLog.fromDocument(String id, Map<String, dynamic> data) {
    Object? first(List<String> fields) {
      for (final field in fields) {
        final value = data[field];
        if (value != null) return value;
      }
      return null;
    }

    String? text(List<String> fields) {
      for (final field in fields) {
        final value = UserRecord.readText(data[field]);
        if (value != null) return value;
      }
      return null;
    }

    num? number(List<String> fields) {
      for (final field in fields) {
        final value = _readNumber(data[field]);
        if (value != null) return value;
      }
      return null;
    }

    DateTime? date(List<String> fields) {
      for (final field in fields) {
        final value = _readDate(data[field]);
        if (value != null) return value;
      }
      return null;
    }

    final hostEarningPaise = _readNumber(data[legacyHostEarningPaiseField]);
    final customerId = text([customerIdField]) ?? '';
    final hostId = text([hostIdField, legacyHostIdField]) ?? '';
    final customerUserId = text([customerUserIdField]);
    final hostUserId = text([hostUserIdField]);
    final status = CallLogStatus.fromValue(
      first([statusField, legacyStatusField]),
    );
    final endReason = text([endReasonField]);
    final rawEndedBy = first([endedByField, legacyEndedByField]);
    final duration = number([durationSecondsField, legacyDurationField]);
    final isLowBalance = data[insufficientBalanceField] == true;

    return CallLog(
      callId: id,
      channelId: text([channelIdField]),
      customerId: customerId,
      hostId: hostId,
      customerUserId: customerUserId,
      hostUserId: hostUserId,
      userName:
          text([customerNameField, legacyCustomerNameField]) ??
          AppStrings.emptyValue,
      hostName:
          text([hostNameField, legacyHostNameField]) ?? AppStrings.emptyValue,
      type: CallLogType.fromValue(first([callTypeField])),
      status: status,
      initiatedAt:
          date([createdAtField]) ?? DateTime.fromMillisecondsSinceEpoch(0),
      startedAt: date([startedAtField, legacyStartedAtField]),
      endedAt: date([endedAtField, legacyEndedAtField]),
      recordedDurationSeconds: duration?.round(),
      endedBy:
          _isLowBalanceEnding(
            endReason: endReason,
            isLowBalance: isLowBalance,
            status: status,
          )
          ? CallEndedBy.user
          : _resolveEndedBy(
              rawEndedBy: rawEndedBy,
              endedUserId: text([endedUserIdField]),
              customerIds: [customerId, ?customerUserId],
              hostIds: [hostId, ?hostUserId],
              endReason: endReason,
              status: status,
              endRequestedBy: data[endRequestedByField],
              left: data[leftField],
            ),
      endReason: endReason,
      spendCoins:
          number([
            coinsChargedField,
            ...legacyCoinsChargedFields,
          ])?.round() ??
          0,
      spendRupees:
          number([amountChargedField, legacyAmountChargedField])?.toDouble() ??
          0,
      hostEarnings:
          number([
            hostEarningsField,
            legacyHostEarningField,
            legacyHostRupeesField,
          ])?.toDouble() ??
          (hostEarningPaise == null ? 0 : hostEarningPaise / _paisePerRupee),
      adminRevenue:
          number([
            adminEarningsField,
            legacyAdminEarningField,
            legacyAdminRupeesField,
          ])?.toDouble() ??
          0,
      // Cloud Functions store `coinsPerSecond` with 6 decimals (₹10/min is
      // 2.5 coins a second), so it must not be rounded.
      coinsPerSecond:
          number([coinsPerSecondField])?.toDouble() ?? _defaultCoinsPerSecond,
      coinsPerRupee:
          number([coinsPerRupeeField])?.toDouble() ?? _defaultCoinsPerRupee,
      hostRatePerMinute:
          number([hostRupeesPerMinuteField])?.toDouble() ??
          _defaultHostRupeesPerMinute,
      storedAdminRatePerMinute: number([
        adminRupeesPerMinuteField,
      ])?.toDouble(),
      isLowBalance: isLowBalance,
    );
  }

  /// The calling app's Cloud Functions write `endReason: lowBalance` when
  /// the caller's balance ran out. Calls settled before that reason existed
  /// are recognised by `insufficientBalance` on a call that ended with a
  /// plain hang-up.
  static bool _isLowBalanceEnding({
    required String? endReason,
    required bool isLowBalance,
    required CallLogStatus status,
  }) {
    if (endReason == lowBalanceReason) return true;
    return isLowBalance &&
        status == CallLogStatus.completed &&
        (endReason == null ||
            endReason == participantLeftReason ||
            endReason == endedByParticipantReason);
  }

  static num? _readNumber(Object? value) => switch (value) {
    num() when value.isFinite => value,
    String() => num.tryParse(value.trim()),
    _ => null,
  };

  /// Firestore timestamps, plus the epoch numbers (seconds or milliseconds),
  /// ISO strings and `{seconds, nanoseconds}` maps older writers used.
  static DateTime? _readDate(Object? value) {
    switch (value) {
      case Timestamp():
        return value.toDate();
      case DateTime():
        return value;
      case num() when value.isFinite && value > 0:
        final millis = value < _millisThreshold ? value * 1000 : value;
        return DateTime.fromMillisecondsSinceEpoch(millis.round());
      case String():
        final trimmed = value.trim();
        final epoch = num.tryParse(trimmed);
        return epoch != null ? _readDate(epoch) : DateTime.tryParse(trimmed);
      case Map():
        final seconds = _readNumber(value['seconds'] ?? value['_seconds']);
        if (seconds == null) return null;
        final nanos =
            _readNumber(value['nanoseconds'] ?? value['_nanoseconds']) ?? 0;
        return DateTime.fromMicrosecondsSinceEpoch(
          (seconds * 1000000 + nanos / 1000).round(),
        );
      default:
        return null;
    }
  }

  /// Who ended the call. `endedBy` is used when it holds a role. When it is
  /// missing (older or partly written documents), the party is worked out
  /// the same way the calling app's Cloud Functions decide it: from the
  /// user ID that ended it, the end reason, the final status, the end
  /// request and finally whoever left the Agora channel first.
  ///
  /// A call the host let ring out is the host's ending: Cloud Functions
  /// store the ring timeout as `endedBy: system` with `endReason: noAnswer`
  /// (status `missed`), and older documents may carry only the `missed`
  /// status. `hostUnreachable` stays a system ending.
  static CallEndedBy? _resolveEndedBy({
    required Object? rawEndedBy,
    required String? endedUserId,
    required List<String> customerIds,
    required List<String> hostIds,
    required String? endReason,
    required CallLogStatus status,
    required Object? endRequestedBy,
    required Object? left,
  }) {
    final stored = CallEndedBy.fromValue(rawEndedBy);
    if (endReason == noAnswerReason &&
        (stored == null || stored == CallEndedBy.system)) {
      return CallEndedBy.host;
    }
    if (stored != null) return stored;

    // Some old documents kept the ender's user ID instead of a role.
    for (final userId in [endedUserId, UserRecord.readText(rawEndedBy)]) {
      if (userId == null) continue;
      if (customerIds.contains(userId)) return CallEndedBy.user;
      if (hostIds.contains(userId)) return CallEndedBy.host;
    }

    final byReason = switch (endReason) {
      cancelledByCustomerReason => CallEndedBy.user,
      rejectedByHostReason => CallEndedBy.host,
      hostUnreachableReason ||
      connectionFailedReason ||
      maxDurationReason => CallEndedBy.system,
      _ => null,
    };
    if (byReason != null) return byReason;

    final byStatus = switch (status) {
      CallLogStatus.cancelled => CallEndedBy.user,
      CallLogStatus.rejected || CallLogStatus.missed => CallEndedBy.host,
      CallLogStatus.failed => CallEndedBy.system,
      _ => null,
    };
    if (byStatus != null) return byStatus;

    final requested = CallEndedBy.fromValue(endRequestedBy);
    if (requested != null) return requested;

    if (left is Map) {
      final customerLeft = _readNumber(left[CallEndedBy.user.value]);
      final hostLeft = _readNumber(left[CallEndedBy.host.value]);
      if (customerLeft != null && hostLeft != null) {
        return customerLeft <= hostLeft ? CallEndedBy.user : CallEndedBy.host;
      }
    }
    return null;
  }

  static const String collection = 'calls';

  /// The Agora channel the call ran on; Cloud Functions set it to the call
  /// ID. Shown as the Session ID.
  static const String channelIdField = 'channelId';
  static const String customerIdField = 'customerId';
  static const String hostIdField = 'hostId';
  static const String customerUserIdField = 'customerUserId';
  static const String hostUserIdField = 'hostUserId';
  static const String customerNameField = 'customerName';
  static const String hostNameField = 'hostName';
  static const String callTypeField = 'callType';
  static const String statusField = 'status';
  static const String createdAtField = 'createdAt';
  static const String startedAtField = 'startedAt';
  static const String endedAtField = 'endedAt';
  static const String durationSecondsField = 'durationSeconds';
  static const String endedByField = 'endedBy';
  static const String endReasonField = 'endReason';
  static const String coinsChargedField = 'coinsCharged';
  static const String amountChargedField = 'amountCharged';
  static const String hostEarningsField = 'hostEarnings';
  static const String adminEarningsField = 'adminEarnings';

  /// Field names written before the calls backend renamed them; older call
  /// documents that were never migrated still carry only these.
  static const String legacyHostEarningField = 'hostEarning';
  static const String legacyAdminEarningField = 'platformEarning';
  static const String legacyHostRupeesField = 'rupeeGotByHost';
  static const String legacyHostEarningPaiseField = 'hostEarningPaise';
  static const String legacyAdminRupeesField = 'rupeeGotByAdmin';
  static const String legacyAmountChargedField = 'rupeeSpentByUser';
  static const List<String> legacyCoinsChargedFields = ['coinDue', 'coinsDue'];
  static const String legacyStartedAtField = 'callStart';
  static const String legacyEndedAtField = 'callEnd';
  static const String legacyEndedByField = 'callEndedBy';
  static const String legacyStatusField = 'callStatus';
  static const String legacyDurationField = 'durationInSeconds';
  static const String legacyHostIdField = 'receiverId';
  static const String legacyHostNameField = 'receiverName';
  static const String legacyCustomerNameField = 'callerName';

  /// User ID of whoever ended the call; null when the system did.
  static const String endedUserIdField = 'callEndedUserId';
  static const String endRequestedByField = 'endRequestedBy';

  /// Agora leave times by role (`customer` / `host`), in epoch seconds.
  static const String leftField = 'left';
  static const String coinsPerSecondField = 'coinsPerSecond';
  static const String coinsPerRupeeField = 'coinsPerRupee';
  static const String hostRupeesPerMinuteField = 'hostRupeesPerMinute';
  static const String adminRupeesPerMinuteField = 'adminRupeesPerMinute';
  static const String insufficientBalanceField = 'insufficientBalance';

  static const String noAnswerReason = 'noAnswer';
  static const String hostUnreachableReason = 'hostUnreachable';
  static const String connectionFailedReason = 'connectionFailed';
  static const String webhookMissingReason = 'webhookMissing';
  static const String maxDurationReason = 'maxDuration';
  static const String cancelledByCustomerReason = 'cancelledByCustomer';
  static const String rejectedByHostReason = 'rejectedByHost';
  static const String lowBalanceReason = 'lowBalance';
  static const String participantLeftReason = 'participantLeft';
  static const String endedByParticipantReason = 'endedByParticipant';

  static const int _paisePerRupee = 100;

  /// Epoch values below this are seconds, at or above it milliseconds
  /// (10^11 seconds is the year 5138; 10^11 milliseconds is 1973).
  static const int _millisThreshold = 100000000000;

  static const double _defaultCoinsPerSecond = 2;
  static const double _defaultCoinsPerRupee = 15;
  static const double _defaultHostRupeesPerMinute = 2;

  final String callId;
  final String customerId;
  final String hostId;
  final String? customerUserId;
  final String? hostUserId;
  final String userName;
  final String hostName;
  final CallLogType type;
  final CallLogStatus status;
  final DateTime initiatedAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int? recordedDurationSeconds;
  final CallEndedBy? endedBy;
  final String? endReason;
  final int spendCoins;
  final double spendRupees;
  final double hostEarnings;
  final double adminRevenue;
  final double coinsPerSecond;
  final double coinsPerRupee;
  final double hostRatePerMinute;

  /// `adminRupeesPerMinute` as written when the call was created, surge
  /// included; null on calls created before that field existed.
  final double? storedAdminRatePerMinute;
  final bool isLowBalance;
  final String? userPhone;
  final String? _channelId;

  /// `channelId`, or the call ID when the document has none, the same
  /// fallback the calling app's `CallModel` uses.
  String get sessionId => _channelId ?? callId;

  bool get endedForLowBalance => _isLowBalanceEnding(
    endReason: endReason,
    isLowBalance: isLowBalance,
    status: status,
  );

  String get userDisplayId => customerUserId ?? customerId;

  String get hostDisplayId => hostUserId ?? hostId;

  /// Talk time: the billed `durationSeconds` when it is positive, otherwise
  /// the gap between start and end. Null for calls that never connected
  /// and for calls still in progress.
  int? get durationSeconds {
    final recorded = recordedDurationSeconds;
    if (recorded != null && recorded > 0) return recorded;
    final started = startedAt;
    final ended = endedAt;
    if (started == null) return null;
    if (ended == null) return recorded;
    final elapsed = ended.difference(started).inSeconds;
    return elapsed >= 0 ? elapsed : recorded;
  }

  double get adminRatePerMinute =>
      storedAdminRatePerMinute ??
      math.max(
        coinsPerSecond * Duration.secondsPerMinute / coinsPerRupee -
            hostRatePerMinute,
        0,
      );

  CallLog withUser(UserRecord? user) => CallLog(
    callId: callId,
    channelId: _channelId,
    customerId: customerId,
    hostId: hostId,
    customerUserId: customerUserId ?? user?.userID,
    hostUserId: hostUserId,
    userName: userName == AppStrings.emptyValue
        ? user?.userName ?? user?.name ?? userName
        : userName,
    hostName: hostName,
    type: type,
    status: status,
    initiatedAt: initiatedAt,
    startedAt: startedAt,
    endedAt: endedAt,
    recordedDurationSeconds: recordedDurationSeconds,
    endedBy: endedBy,
    endReason: endReason,
    spendCoins: spendCoins,
    spendRupees: spendRupees,
    hostEarnings: hostEarnings,
    adminRevenue: adminRevenue,
    coinsPerSecond: coinsPerSecond,
    coinsPerRupee: coinsPerRupee,
    hostRatePerMinute: hostRatePerMinute,
    storedAdminRatePerMinute: storedAdminRatePerMinute,
    isLowBalance: isLowBalance,
    userPhone: user?.phoneLabel,
  );
}
