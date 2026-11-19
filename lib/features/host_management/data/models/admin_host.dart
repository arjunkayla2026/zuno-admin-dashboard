import 'package:zuno_admin_dashboard/core/utils/name_formatter.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/host_profile_options.dart';

enum HostStatus { active, inactive, blocked, deletedByAdmin, deletedByUser }

class AdminHost {
  const AdminHost({
    required this.createdDate,
    required this.name,
    required this.fullName,
    required this.hostId,
    required this.phone,
    required this.walletBalance,
    required this.status,
    required this.avatarIndex,
    this.isNew = false,
    this.isAccountActive = true,
    this.dateOfBirth,
    this.district = '',
    this.state = '',
    this.gender,
    this.motherTongue,
    this.languages = const {},
    this.aadhaarImageUrl,
    this.aadhaarBackImageUrl,
    this.selfieImageUrl,
    this.profileImageUrl,
    this.totalRevenue = 0,
    this.availableBalance = 0,
    this.totalAdminCredit,
    this.totalAdminDebit,
    this.totalWithdrawn,
    this.isOnline = false,
    this.lastOnline,
    this.approvedAt,
    String? userID,
  }) : userID = userID ?? hostId;

  final String createdDate;
  final String name;
  final String fullName;
  final String hostId;
  final String userID;
  final String phone;
  final int walletBalance;
  final HostStatus status;
  final int avatarIndex;
  final bool isNew;
  final bool isAccountActive;
  final DateTime? dateOfBirth;
  final String district;
  final String state;
  final HostGender? gender;
  final HostLanguage? motherTongue;
  final Set<HostLanguage> languages;
  final String? aadhaarImageUrl;
  final String? aadhaarBackImageUrl;
  final String? selfieImageUrl;

  /// The host's profile picture (`avatharImage`).
  final String? profileImageUrl;
  final double totalRevenue;
  final double availableBalance;

  /// `hostDetails.hostEarnings.totalAdminCredit` / `totalAdminDebit`: every
  /// admin credit / debit, kept by the calling app's `adjustHostEarnings`.
  /// Null on hosts whose map does not have them yet (before the backend
  /// update and its backfill); Host Details then adds up the ledger.
  final double? totalAdminCredit;
  final double? totalAdminDebit;

  bool get hasStoredAdminTotals =>
      totalAdminCredit != null && totalAdminDebit != null;

  /// Paid payouts before TDS: `hostDetails.hostEarnings.totalWithdrawel`
  /// (stored spelling), which the calling app's `completeHostPayouts` adds to
  /// once per payout, or the older `hostDetails.totalWithdrawn`. Null when
  /// the host has neither.
  final double? totalWithdrawn;
  final bool isOnline;
  final DateTime? lastOnline;

  /// `hostDetails.approvedAt`: when an admin approved the host request.
  /// Null for hosts approved before the date was recorded.
  final DateTime? approvedAt;

  String get initials => NameFormatter.initials(name);

  bool get isDeleted =>
      status == HostStatus.deletedByAdmin || status == HostStatus.deletedByUser;

  bool get hasActions =>
      status != HostStatus.deletedByAdmin && status != HostStatus.deletedByUser;

  AdminHost copyWith({
    String? name,
    String? fullName,
    String? phone,
    int? walletBalance,
    HostStatus? status,
    DateTime? dateOfBirth,
    String? district,
    String? state,
    HostGender? gender,
    HostLanguage? motherTongue,
    Set<HostLanguage>? languages,
    double? totalAdminCredit,
    double? totalAdminDebit,
  }) {
    return AdminHost(
      createdDate: createdDate,
      name: name ?? this.name,
      fullName: fullName ?? this.fullName,
      hostId: hostId,
      userID: userID,
      phone: phone ?? this.phone,
      walletBalance: walletBalance ?? this.walletBalance,
      status: status ?? this.status,
      avatarIndex: avatarIndex,
      isNew: isNew,
      isAccountActive: isAccountActive,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      district: district ?? this.district,
      state: state ?? this.state,
      gender: gender ?? this.gender,
      motherTongue: motherTongue ?? this.motherTongue,
      languages: languages ?? this.languages,
      aadhaarImageUrl: aadhaarImageUrl,
      aadhaarBackImageUrl: aadhaarBackImageUrl,
      selfieImageUrl: selfieImageUrl,
      profileImageUrl: profileImageUrl,
      totalRevenue: totalRevenue,
      availableBalance: availableBalance,
      totalAdminCredit: totalAdminCredit ?? this.totalAdminCredit,
      totalAdminDebit: totalAdminDebit ?? this.totalAdminDebit,
      totalWithdrawn: totalWithdrawn,
      isOnline: isOnline,
      lastOnline: lastOnline,
      approvedAt: approvedAt,
    );
  }
}
