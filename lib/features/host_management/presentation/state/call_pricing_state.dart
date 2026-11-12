import 'package:zuno_admin_dashboard/core/data/host_pricing.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';

class CallPricingState {
  const CallPricingState({
    this.status = LoadStatus.loading,
    this.pricing,
    this.errorMessage,
  });

  final LoadStatus status;
  final HostPricing? pricing;
  final String? errorMessage;
}
