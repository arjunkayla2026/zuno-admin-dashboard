import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

abstract final class AppLogger {
  static const String _name = 'zuno';
  static const int _maxLength = 500;

  static void info(String message) {
    if (!kDebugMode) return;
    developer.log(message, name: _name);
  }

  static void error(String message, Object error, [StackTrace? stackTrace]) {
    if (!kDebugMode) return;
    developer.log(
      message,
      name: _name,
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }

  static String describe(Object? value) {
    final text = switch (value) {
      Iterable<Object?>() => '${value.runtimeType}(${value.length})',
      Map<Object?, Object?>() => '${value.runtimeType}(${value.length})',
      _ => '$value',
    };
    return text.length <= _maxLength
        ? text
        : '${text.substring(0, _maxLength)}…';
  }
}
