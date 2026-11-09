import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/date_range_filter.dart';
import 'package:zuno_admin_dashboard/features/approval/data/mock/approval_mock_data.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/host_request.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/payout_request.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/profile_photo_request.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/state/approval_state.dart';

class ApprovalCubit extends Cubit<ApprovalState> {
  ApprovalCubit()
    : super(
        ApprovalState(
          hostRequests: ApprovalMockData.hostRequests,
          payoutRequests: ApprovalMockData.payoutRequests,
          profilePhotoRequests: ApprovalMockData.profilePhotoRequests,
          today: ApprovalMockData.today,
        ),
      );

  void selectTab(ApprovalTab tab) => emit(state.copyWith(tab: tab));

  void search(String query) => emit(state.copyWith(query: query));

  void selectDateFilter(DateRangeFilter filter) =>
      emit(state.copyWith(dateFilter: filter));

  void selectCustomRange(DateTimeRange range) => emit(
    state.copyWith(dateFilter: DateRangeFilter.custom, customRange: range),
  );

  void updateRequest(HostRequest request) => emit(
    state.copyWith(
      hostRequests: [
        for (final current in state.hostRequests)
          current.requestId == request.requestId ? request : current,
      ],
    ),
  );

  void updatePayout(PayoutRequest payout) => emit(
    state.copyWith(
      payoutRequests: [
        for (final current in state.payoutRequests)
          current.payoutId == payout.payoutId ? payout : current,
      ],
    ),
  );

  void updateProfilePhoto(ProfilePhotoRequest photo) => emit(
    state.copyWith(
      profilePhotoRequests: [
        for (final current in state.profilePhotoRequests)
          current.requestId == photo.requestId ? photo : current,
      ],
    ),
  );
}
