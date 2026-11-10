import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/enums/date_range_filter.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/host_request.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/payout_request.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/profile_photo_request.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/state/approval_pager.dart';

enum ApprovalTab { hostRequests, payoutReview, profilePhotoReview }

class ApprovalState {
  const ApprovalState({
    required this.hostRequests,
    required this.payoutRequests,
    required this.profilePhotoRequests,
    required this.today,
    this.hostRequestsStatus = LoadStatus.loaded,
    this.hostRequestsError,
    this.hostPaging = const ApprovalPaging(),
    this.pendingCount = 0,
    this.profilePhotosStatus = LoadStatus.loaded,
    this.profilePhotosError,
    this.photoPaging = const ApprovalPaging(),
    this.pendingPhotoCount = 0,
    this.payoutsStatus = LoadStatus.loaded,
    this.payoutsError,
    this.payoutPaging = const ApprovalPaging(),
    this.pendingPayoutCount = 0,
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
  final ApprovalPaging hostPaging;
  final int pendingCount;
  final LoadStatus profilePhotosStatus;
  final String? profilePhotosError;
  final ApprovalPaging photoPaging;
  final int pendingPhotoCount;
  final LoadStatus payoutsStatus;
  final String? payoutsError;
  final ApprovalPaging payoutPaging;
  final int pendingPayoutCount;
  final ApprovalTab tab;
  final String query;
  final DateRangeFilter dateFilter;
  final DateTimeRange? customRange;

  ApprovalState copyWith({
    List<HostRequest>? hostRequests,
    List<PayoutRequest>? payoutRequests,
    List<ProfilePhotoRequest>? profilePhotoRequests,
    LoadStatus? hostRequestsStatus,
    String? hostRequestsError,
    ApprovalPaging? hostPaging,
    int? pendingCount,
    LoadStatus? profilePhotosStatus,
    String? profilePhotosError,
    ApprovalPaging? photoPaging,
    int? pendingPhotoCount,
    LoadStatus? payoutsStatus,
    String? payoutsError,
    ApprovalPaging? payoutPaging,
    int? pendingPayoutCount,
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
      hostPaging: hostPaging ?? this.hostPaging,
      pendingCount: pendingCount ?? this.pendingCount,
      profilePhotosStatus: profilePhotosStatus ?? this.profilePhotosStatus,
      profilePhotosError: profilePhotosError ?? this.profilePhotosError,
      photoPaging: photoPaging ?? this.photoPaging,
      pendingPhotoCount: pendingPhotoCount ?? this.pendingPhotoCount,
      payoutsStatus: payoutsStatus ?? this.payoutsStatus,
      payoutsError: payoutsError ?? this.payoutsError,
      payoutPaging: payoutPaging ?? this.payoutPaging,
      pendingPayoutCount: pendingPayoutCount ?? this.pendingPayoutCount,
      tab: tab ?? this.tab,
      query: query ?? this.query,
      dateFilter: dateFilter ?? this.dateFilter,
      customRange: customRange ?? this.customRange,
    );
  }
}
