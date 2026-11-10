import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/data/record_page.dart';
import 'package:zuno_admin_dashboard/core/data/search_keywords.dart';
import 'package:zuno_admin_dashboard/core/enums/date_range_filter.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/utils/date_range_matcher.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/host_request.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/payout_request.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/profile_photo_request.dart';
import 'package:zuno_admin_dashboard/features/approval/data/repositories/approval_repository.dart';
import 'package:zuno_admin_dashboard/features/approval/data/repositories/payout_repository.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/state/approval_pager.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/state/approval_state.dart';

class ApprovalCubit extends Cubit<ApprovalState> {
  ApprovalCubit(
    this._repository,
    this._payoutRepository, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now,
       super(
         ApprovalState(
           hostRequests: const [],
           hostRequestsStatus: LoadStatus.loading,
           payoutRequests: const [],
           payoutsStatus: LoadStatus.loading,
           profilePhotoRequests: const [],
           profilePhotosStatus: LoadStatus.loading,
           today: (now ?? DateTime.now)(),
         ),
       );

  static const Duration _searchDebounce = Duration(milliseconds: 450);

  final ApprovalRepository _repository;
  final PayoutRepository _payoutRepository;
  final DateTime Function() _now;
  Timer? _debounce;

  late final ApprovalPager<HostRequest> _hosts = ApprovalPager(
    fetch: _repository.fetchHostRequests,
    count: _repository.countHostRequests,
    now: _now,
    onChanged: (view) => _publish(
      state.copyWith(
        hostRequests: view.items,
        hostRequestsStatus: view.status,
        hostRequestsError: view.error,
        hostPaging: view.paging,
        pendingCount: view.unfilteredTotal,
      ),
    ),
  );

  late final ApprovalPager<PayoutRequest> _payouts = ApprovalPager(
    fetch: _payoutRepository.fetchPayoutRequests,
    count: _payoutRepository.countPayoutRequests,
    now: _now,
    onChanged: (view) => _publish(
      state.copyWith(
        payoutRequests: view.items,
        payoutsStatus: view.status,
        payoutsError: view.error,
        payoutPaging: view.paging,
        pendingPayoutCount: view.unfilteredTotal,
      ),
    ),
  );

  late final ApprovalPager<ProfilePhotoRequest> _photos = ApprovalPager(
    fetch: _repository.fetchProfilePhotoRequests,
    count: _repository.countProfilePhotoRequests,
    now: _now,
    onChanged: (view) => _publish(
      state.copyWith(
        profilePhotoRequests: view.items,
        profilePhotosStatus: view.status,
        profilePhotosError: view.error,
        photoPaging: view.paging,
        pendingPhotoCount: view.unfilteredTotal,
      ),
    ),
  );

  void _publish(ApprovalState next) {
    if (!isClosed) emit(next);
  }

  ApprovalFilter get _filter {
    final bounds = state.dateFilter.boundsFor(
      today: state.today,
      customRange: state.customRange,
    );
    return ApprovalFilter(
      term: SearchKeywords.normalizeTerm(state.query),
      from: bounds?.$1,
      until: bounds?.$2,
    );
  }

  ApprovalPager<Object?> get _activePager => switch (state.tab) {
    ApprovalTab.hostRequests => _hosts,
    ApprovalTab.payoutReview => _payouts,
    ApprovalTab.profilePhotoReview => _photos,
  };

  Future<void> initialize() async {
    await Future.wait([_hosts.show(_filter), _loadOtherTabCounts()]);
  }

  Future<void> _loadOtherTabCounts() async {
    const query = RecordPageQuery();
    final (payouts, photos) = await (
      _payoutRepository.countPayoutRequests(query),
      _repository.countProfilePhotoRequests(query),
    ).wait;
    _publish(
      state.copyWith(
        pendingPayoutCount: payouts.toNullable(),
        pendingPhotoCount: photos.toNullable(),
      ),
    );
  }

  Future<void> loadHostRequests() => _hosts.show(_filter, force: true);

  Future<void> loadPayoutRequests() => _payouts.show(_filter, force: true);

  Future<void> loadProfilePhotos() => _photos.show(_filter, force: true);

  void goToPage(int page) => _activePager.show(_filter, page: page);

  void selectTab(ApprovalTab tab) {
    emit(state.copyWith(tab: tab));
    _applyFilters();
  }

  void search(String query) {
    emit(state.copyWith(query: query));
    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, _applyFilters);
  }

  void selectDateFilter(DateRangeFilter filter) {
    emit(state.copyWith(dateFilter: filter));
    _applyFilters();
  }

  void selectCustomRange(DateTimeRange range) {
    emit(
      state.copyWith(dateFilter: DateRangeFilter.custom, customRange: range),
    );
    _applyFilters();
  }

  void _applyFilters() {
    _debounce?.cancel();
    final filter = _filter;
    if (_activePager.appliedKey != filter.key) _activePager.show(filter);
  }

  Future<String?> decideRequest(
    HostRequest request,
    HostRequestStatus decision,
  ) async {
    final result = await _repository.decideRequest(request, decision);
    if (isClosed) return null;

    return result.match((failure) => failure.message, (_) {
      _hosts
        ..recordDecision()
        ..update(
          (item) => item.requestId == request.requestId
              ? item.copyWith(status: decision)
              : item,
        );
      _publish(state.copyWith(pendingCount: max(0, state.pendingCount - 1)));
      return null;
    });
  }

  Future<String?> reviewDocument(
    HostRequest request,
    HostDocumentType type,
    HostRequestStatus decision,
  ) async {
    final result = await _repository.reviewDocument(request, type, decision);
    if (isClosed) return null;

    return result.match((failure) => failure.message, (_) {
      updateRequest(request.withDocumentStatus(type, decision));
      return null;
    });
  }

  Future<String?> decideProfilePhoto(
    ProfilePhotoRequest photo,
    ProfilePhotoStatus decision,
  ) async {
    updateProfilePhoto(photo.copyWith(isDeciding: true));
    final result = await _repository.decideProfilePhoto(photo, decision);
    if (isClosed) return null;

    return result.match(
      (failure) {
        updateProfilePhoto(photo);
        return failure.message;
      },
      (_) {
        _photos.recordDecision();
        updateProfilePhoto(photo.copyWith(status: decision));
        _publish(
          state.copyWith(
            pendingPhotoCount: max(0, state.pendingPhotoCount - 1),
          ),
        );
        return null;
      },
    );
  }

  Future<String?> decidePayout(
    PayoutRequest payout,
    PayoutRequestStatus decision,
  ) async {
    final result = await _payoutRepository.decide(payout, decision);
    if (isClosed) return null;

    return result.match((failure) => failure.message, (_) {
      _payouts.recordDecision();
      updatePayout(payout.copyWith(status: decision));
      _publish(
        state.copyWith(
          pendingPayoutCount: max(0, state.pendingPayoutCount - 1),
        ),
      );
      return null;
    });
  }

  void updateRequest(HostRequest request) => _hosts.update(
    (item) => item.requestId == request.requestId ? request : item,
  );

  void updatePayout(PayoutRequest payout) => _payouts.update(
    (item) => item.payoutId == payout.payoutId ? payout : item,
  );

  void updateProfilePhoto(ProfilePhotoRequest photo) => _photos.update(
    (item) => item.requestId == photo.requestId ? photo : item,
  );

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
