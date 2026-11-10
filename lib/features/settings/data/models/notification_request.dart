import 'package:zuno_admin_dashboard/features/host_management/data/models/host_profile_options.dart';

enum NotificationAudience {
  users('user'),
  hosts('host'),
  both('both');

  const NotificationAudience(this.key);

  final String key;

  bool get includesUsers => this != hosts;

  bool get includesHosts => this != users;
}

class NotificationRequest {
  const NotificationRequest({
    required this.title,
    required this.message,
    required this.audience,
    this.motherTongues = const {},
  });

  static const int titleMaxLength = 100;
  static const int messageMaxLength = 1000;

  final String title;
  final String message;
  final NotificationAudience audience;
  final Set<HostLanguage> motherTongues;

  Map<String, Object> toPayload() => {
    'title': title,
    'message': message,
    'audience': audience.key,
    'motherTongues': [
      if (audience.includesHosts)
        for (final language in HostLanguage.values)
          if (motherTongues.contains(language)) language.name,
    ],
  };
}

class NotificationSendResult {
  const NotificationSendResult({
    required this.recipientCount,
    required this.successCount,
    required this.failureCount,
    required this.missingTokenCount,
  });

  factory NotificationSendResult.fromMap(Map<Object?, Object?> data) {
    int count(String key) => switch (data[key]) {
      final num value => value.toInt(),
      _ => 0,
    };

    return NotificationSendResult(
      recipientCount: count('recipientCount'),
      successCount: count('successCount'),
      failureCount: count('failureCount'),
      missingTokenCount: count('missingTokenCount'),
    );
  }

  final int recipientCount;
  final int successCount;
  final int failureCount;
  final int missingTokenCount;
}
