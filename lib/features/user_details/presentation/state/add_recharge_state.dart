import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/features/user_details/data/models/recharge_package.dart';

class AddRechargeState {
  const AddRechargeState({
    this.status = LoadStatus.loading,
    this.packages = const [],
    this.errorMessage,
    this.isSubmitting = false,
    this.submitError,
  });

  final LoadStatus status;
  final List<RechargePackage> packages;
  final String? errorMessage;
  final bool isSubmitting;
  final String? submitError;

  AddRechargeState copyWith({bool? isSubmitting, String? submitError}) {
    return AddRechargeState(
      status: status,
      packages: packages,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError,
    );
  }
}
