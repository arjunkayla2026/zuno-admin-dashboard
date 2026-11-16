import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';

/// Rupees earned from settled calls in a date range, split by call type and
/// by who received the money.
class CallRevenue {
  const CallRevenue({
    this.hostAudio = 0,
    this.hostVideo = 0,
    this.adminAudio = 0,
    this.adminVideo = 0,
  });

  final double hostAudio;
  final double hostVideo;
  final double adminAudio;
  final double adminVideo;

  double get admin => NumberFormatter.roundAmount(adminAudio + adminVideo);
}
