import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/app_environment/config/firebase_options_staging.dart'
    as stg;
import 'package:zuno_admin_dashboard/core/enums/app_environment.dart';

class FlavorConfig {
  final Environment environment;

  static FlavorConfig? _instance;

  FlavorConfig._({required this.environment});

  factory FlavorConfig({required Environment environment}) {
    return _instance ??= FlavorConfig._(environment: environment);
  }

  static FlavorConfig get instance {
    if (_instance == null) {
      throw Exception('FlavorConfig not initialized');
    }
    return _instance!;
  }

  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    switch (environment) {
      case Environment.production:
        break;
      case Environment.staging:
        await Firebase.initializeApp(
          options: stg.DefaultFirebaseOptions.currentPlatform,
        );
    }
  }
}
