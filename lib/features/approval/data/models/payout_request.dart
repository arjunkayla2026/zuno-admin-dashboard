import 'package:zuno_admin_dashboard/core/utils/name_formatter.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/admin_host.dart';

enum PayoutRequestStatus { pending, accepted, rejected }

class PayoutRequest {
  const PayoutRequest({
    required this.payoutId,
    required this.submittedOn,
    required this.hostName,
    required this.hostId,
    required this.realName,
    required this.phone,
    required this.location,
    required this.hostStatus,
    required this.accountHolderName,
    required this.branchName,
    required this.accountNumber,
    required this.ifscCode,
    required this.avatarIndex,
    this.status = PayoutRequestStatus.pending,
  });

  static const int _visibleDigits = 4;

  final String payoutId;
  final DateTime submittedOn;
  final String hostName;
  final String hostId;
  final String realName;
  final String phone;
  final String location;
  final HostStatus hostStatus;
  final String accountHolderName;
  final String branchName;
  final String accountNumber;
  final String ifscCode;
  final int avatarIndex;
  final PayoutRequestStatus status;

  String get initials => NameFormatter.initials(hostName);

  bool get isPending => status == PayoutRequestStatus.pending;

  String get accountLastDigits => accountNumber.length <= _visibleDigits
      ? accountNumber
      : accountNumber.substring(accountNumber.length - _visibleDigits);

  PayoutRequest copyWith({PayoutRequestStatus? status}) {
    return PayoutRequest(
      payoutId: payoutId,
      submittedOn: submittedOn,
      hostName: hostName,
      hostId: hostId,
      realName: realName,
      phone: phone,
      location: location,
      hostStatus: hostStatus,
      accountHolderName: accountHolderName,
      branchName: branchName,
      accountNumber: accountNumber,
      ifscCode: ifscCode,
      avatarIndex: avatarIndex,
      status: status ?? this.status,
    );
  }
}
