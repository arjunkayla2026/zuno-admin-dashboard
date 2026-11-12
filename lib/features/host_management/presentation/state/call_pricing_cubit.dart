import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/data/host_pricing.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/call_pricing_state.dart';
import 'package:zuno_admin_dashboard/features/settings/data/repositories/settings_repository.dart';

class CallPricingCubit extends Cubit<CallPricingState> {
  CallPricingCubit(this._repository) : super(const CallPricingState());

  final SettingsRepository _repository;
  Future<void>? _loading;

  Future<void> load() => _loading ??= _load();

  Future<void> _load() async {
    emit(CallPricingState(pricing: state.pricing));
    final result = await _repository.fetchHostPricing();
    _loading = null;
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => CallPricingState(
          status: LoadStatus.failure,
          pricing: state.pricing,
          errorMessage: failure.message,
        ),
        (pricing) =>
            CallPricingState(status: LoadStatus.loaded, pricing: pricing),
      ),
    );
  }

  Future<String?> save(HostPricing pricing) async {
    final result = await _repository.saveHostPricing(pricing);
    return result.fold((failure) => failure.message, (_) {
      if (!isClosed) {
        emit(CallPricingState(status: LoadStatus.loaded, pricing: pricing));
      }
      return null;
    });
  }
}
