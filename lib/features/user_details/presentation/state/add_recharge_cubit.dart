import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/features/packages/data/repositories/packages_repository.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/models/recharge_transaction.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/repositories/recharge_repository.dart';
import 'package:zuno_admin_dashboard/features/user_details/data/models/recharge_package.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/add_recharge_state.dart';

class AddRechargeCubit extends Cubit<AddRechargeState> {
  AddRechargeCubit(this._packages, this._recharges)
    : super(const AddRechargeState());

  final PackagesRepository _packages;
  final RechargeRepository _recharges;

  Future<void> loadPackages() async {
    emit(const AddRechargeState());
    final result = await _packages.fetchActivePackages();
    if (isClosed) return;
    result.match(
      (failure) => emit(
        AddRechargeState(
          status: LoadStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (plans) => emit(
        AddRechargeState(
          status: LoadStatus.loaded,
          packages: plans.map(RechargePackage.fromPlan).toList(),
        ),
      ),
    );
  }

  String newRequestId() => _recharges.newTransactionId();

  Future<AdminRechargeResult?> submit({
    required String userId,
    required RechargePackage package,
    required String requestId,
  }) async {
    if (state.isSubmitting) return null;
    emit(state.copyWith(isSubmitting: true));
    final result = await _recharges.addAdminRecharge(
      userId: userId,
      packageId: package.id,
      expectedAmount: package.price,
      requestId: requestId,
    );
    if (isClosed) return null;
    emit(
      state.copyWith(
        isSubmitting: false,
        submitError: result.getLeft().toNullable()?.message,
      ),
    );
    return result.toNullable();
  }
}
