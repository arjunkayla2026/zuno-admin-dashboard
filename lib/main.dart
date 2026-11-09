import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/app_environment/config/flavor_config.dart';
import 'package:zuno_admin_dashboard/core/di/injection_container.dart';
import 'package:zuno_admin_dashboard/core/enums/app_environment.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';

Future<void> flavorMain(Environment environment) async {
  final flavorConfig = FlavorConfig(environment: environment);
  await flavorConfig.init();
  configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
