import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';

enum PricingChannel {
  audio('audio'),
  video('video'),
  message('message');

  const PricingChannel(this.key);

  final String key;
}

enum PricingSide { admin, host }

class ChannelPricing {
  const ChannelPricing({this.adminAmount = 0, this.hostAmount = 0});

  factory ChannelPricing.fromMap(Object? data) {
    if (data is! Map) return const ChannelPricing();
    return ChannelPricing(
      adminAmount: _amount(data[adminAmountField]),
      hostAmount: _amount(data[hostAmountField]),
    );
  }

  static const String adminAmountField = 'adminAmount';
  static const String hostAmountField = 'hostAmount';

  final double adminAmount;
  final double hostAmount;

  double amountFor(PricingSide side) => switch (side) {
    PricingSide.admin => adminAmount,
    PricingSide.host => hostAmount,
  };

  Map<String, Object?> toMap() => {
    adminAmountField: NumberFormatter.roundAmount(adminAmount),
    hostAmountField: NumberFormatter.roundAmount(hostAmount),
  };

  static double _amount(Object? value) =>
      value is num ? NumberFormatter.roundAmount(value.toDouble()) : 0;
}

class HostPricing {
  const HostPricing({
    this.audio = const ChannelPricing(),
    this.video = const ChannelPricing(),
    this.message = const ChannelPricing(),
  });

  factory HostPricing.fromMap(Object? data) {
    if (data is! Map) return const HostPricing();
    return HostPricing(
      audio: ChannelPricing.fromMap(data[PricingChannel.audio.key]),
      video: ChannelPricing.fromMap(data[PricingChannel.video.key]),
      message: ChannelPricing.fromMap(data[PricingChannel.message.key]),
    );
  }

  static const String field = 'setHostPrice';

  final ChannelPricing audio;
  final ChannelPricing video;
  final ChannelPricing message;

  ChannelPricing of(PricingChannel channel) => switch (channel) {
    PricingChannel.audio => audio,
    PricingChannel.video => video,
    PricingChannel.message => message,
  };

  Map<String, Object?> toMap() => {
    for (final channel in PricingChannel.values)
      channel.key: of(channel).toMap(),
  };
}
