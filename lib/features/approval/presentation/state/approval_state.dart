import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/enums/date_range_filter.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/utils/date_range_matcher.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/host_request.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/payout_request.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/profile_photo_request.dart';

enum ApprovalTab { hostRequests, payoutReview, profilePhotoReview }

class ApprovalState {
  const ApprovalState({
    required this.hostRequests,
    required this.payoutRequests,
    required this.profilePhotoRequests,
    required this.today,
    this.hostRequestsStatus = LoadStatus.loaded,
    this.hostRequestsError,
    this.hostRequestsToday,
    this.tab = ApprovalTab.hostRequests,
    this.query = '',
    this.dateFilter = DateRangeFilter.all,
    this.customRange,
  });

  final List<HostRequest> hostRequests;
  final List<PayoutRequest> payoutRequests;
  final List<ProfilePhotoRequest> profilePhotoRequests;
  final DateTime today;
  final LoadStatus hostRequestsStatus;
  final String? hostRequestsError;
  final DateTime? hostRequestsToday;
  final ApprovalTab tab;
  final String query;
  final DateRangeFilter dateFilter;
  final DateTimeRange? customRange;

  int get pendingCount =>
      hostRequests.where((request) => request.isPending).length;

  int get pendingPayoutCount =>
      payoutRequests.where((payout) => payout.isPending).length;

  int get pendingPhotoCount =>
      profilePhotoRequests.where((photo) => photo.isPending).length;

  String get _term => query.trim().toLowerCase();

  String get _digits => _term.replaceAll(' ', '');

  bool _inRange(DateTime date) =>
      dateFilter.includes(date, today: today, customRange: customRange);

  bool _matches(List<String> texts, String phone) {
    final term = _term;
    if (term.isEmpty) return true;
    final digits = _digits;
    return texts.any((text) => text.toLowerCase().contains(term)) ||
        (digits.isNotEmpty && phone.replaceAll(' ', '').contains(digits));
  }

  List<HostRequest> get filteredHostRequests => hostRequests
      .where(
        (request) =>
            dateFilter.includes(
              request.submittedOn,
              today: hostRequestsToday ?? today,
              customRange: customRange,
            ) &&
            _matches([
              request.realName,
              request.nickName,
              request.requestId,
            ], request.phone),
      )
      .toList();

  List<PayoutRequest> get filteredPayoutRequests => payoutRequests
      .where(
        (payout) =>
            _inRange(payout.submittedOn) &&
            _matches([
              payout.hostName,
              payout.realName,
              payout.hostId,
              payout.payoutId,
              payout.accountHolderName,
            ], payout.phone),
      )
      .toList();

  List<ProfilePhotoRequest> get filteredProfilePhotoRequests =>
      profilePhotoRequests
          .where(
            (photo) =>
                _inRange(photo.submittedOn) &&
                _matches([
                  photo.hostName,
                  photo.realName,
                  photo.hostId,
                  photo.city,
                ], ''),
          )
          .toList();

  ApprovalState copyWith({
    List<HostRequest>? hostRequests,
    List<PayoutRequest>? payoutRequests,
    List<ProfilePhotoRequest>? profilePhotoRequests,
    LoadStatus? hostRequestsStatus,
    String? hostRequestsError,
    ApprovalTab? tab,
    String? query,
    DateRangeFilter? dateFilter,
    DateTimeRange? customRange,
  }) {
    return ApprovalState(
      hostRequests: hostRequests ?? this.hostRequests,
      payoutRequests: payoutRequests ?? this.payoutRequests,
      profilePhotoRequests: profilePhotoRequests ?? this.profilePhotoRequests,
      today: today,
      hostRequestsStatus: hostRequestsStatus ?? this.hostRequestsStatus,
      hostRequestsError: hostRequestsError ?? this.hostRequestsError,
      hostRequestsToday: hostRequestsToday,
      tab: tab ?? this.tab,
      query: query ?? this.query,
      dateFilter: dateFilter ?? this.dateFilter,
      customRange: customRange ?? this.customRange,
    );
  }
}
