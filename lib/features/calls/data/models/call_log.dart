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

  final String value;

  static CallLogStatus fromValue(Object? value) {
    if (value == _acceptedValue) return ongoing;
    for (final status in values) {
      if (status.value == value) return status;
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

  static CallEndedBy? fromValue(Object? value) {
    for (final party in values) {
      if (party.value == value) return party;
    }
    return null;
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
    this.isLowBalance = false,
    this.userPhone,
  });

  factory CallLog.fromDocument(String id, Map<String, dynamic> data) {
    int readInt(String field, int fallback) {
      final value = data[field];
      return value is num ? value.round() : fallback;
    }

    double readDouble(String field, double fallback) {
      final value = data[field];
      return value is num ? value.toDouble() : fallback;
    }

    final duration = data[durationSecondsField];
    return CallLog(
      callId: id,
      customerId: UserRecord.readText(data[customerIdField]) ?? '',
      hostId: UserRecord.readText(data[hostIdField]) ?? '',
      customerUserId: UserRecord.readText(data[customerUserIdField]),
      hostUserId: UserRecord.readText(data[hostUserIdField]),
      userName:
          UserRecord.readText(data[customerNameField]) ?? AppStrings.emptyValue,
      hostName:
          UserRecord.readText(data[hostNameField]) ?? AppStrings.emptyValue,
      type: CallLogType.fromValue(data[callTypeField]),
      status: CallLogStatus.fromValue(data[statusField]),
      initiatedAt:
          UserRecord.readDate(data[createdAtField]) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      startedAt: UserRecord.readDate(data[startedAtField]),
      endedAt: UserRecord.readDate(data[endedAtField]),
      recordedDurationSeconds: duration is num ? duration.round() : null,
      endedBy: CallEndedBy.fromValue(data[endedByField]),
      endReason: UserRecord.readText(data[endReasonField]),
      spendCoins: readInt(coinsChargedField, 0),
      spendRupees: readDouble(amountChargedField, 0),
      hostEarnings: readDouble(hostEarningField, 0),
      adminRevenue: readDouble(platformEarningField, 0),
      coinsPerSecond: readInt(coinsPerSecondField, _defaultCoinsPerSecond),
      coinsPerRupee: readInt(coinsPerRupeeField, _defaultCoinsPerRupee),
      hostRatePerMinute: readDouble(
        hostRupeesPerMinuteField,
        _defaultHostRupeesPerMinute,
      ),
      isLowBalance: data[insufficientBalanceField] == true,
    );
  }

  static const String collection = 'calls';
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
  static const String hostEarningField = 'hostEarning';
  static const String platformEarningField = 'platformEarning';
  static const String coinsPerSecondField = 'coinsPerSecond';
  static const String coinsPerRupeeField = 'coinsPerRupee';
  static const String hostRupeesPerMinuteField = 'hostRupeesPerMinute';
  static const String insufficientBalanceField = 'insufficientBalance';

  static const String noAnswerReason = 'noAnswer';
  static const String hostUnreachableReason = 'hostUnreachable';
  static const String connectionFailedReason = 'connectionFailed';
  static const String webhookMissingReason = 'webhookMissing';
  static const String maxDurationReason = 'maxDuration';

  static const int _defaultCoinsPerSecond = 2;
  static const int _defaultCoinsPerRupee = 15;
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
  final int coinsPerSecond;
  final int coinsPerRupee;
  final double hostRatePerMinute;
  final bool isLowBalance;
  final String? userPhone;

  String get userDisplayId => customerUserId ?? customerId;

  String get hostDisplayId => hostUserId ?? hostId;

  int? get durationSeconds {
    final started = startedAt;
    if (started == null) return null;
    return recordedDurationSeconds ?? endedAt?.difference(started).inSeconds;
  }

  double get adminRatePerMinute =>
      coinsPerSecond * Duration.secondsPerMinute / coinsPerRupee -
      hostRatePerMinute;

  CallLog withUser(UserRecord? user) => CallLog(
    callId: callId,
    customerId: customerId,
    hostId: hostId,
    customerUserId: customerUserId ?? user?.userID,
    hostUserId: hostUserId,
    userName: userName == AppStrings.emptyValue
        ? user?.name ?? userName
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
    isLowBalance: isLowBalance,
    userPhone: user?.phoneLabel,
  );
}
