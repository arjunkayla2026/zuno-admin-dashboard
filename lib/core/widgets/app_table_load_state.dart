import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_error_banner.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';

class AppTableLoadingState extends StatelessWidget {
  const AppTableLoadingState({super.key});

  static const double _height = 160;
  static const double _loaderSize = 28;
  static const double _loaderStroke = 2.5;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: Center(
        child: SizedBox.square(
          dimension: _loaderSize,
          child: CircularProgressIndicator(
            strokeWidth: _loaderStroke,
            color: context.appColors.onPrimarySoft,
          ),
        ),
      ),
    );
  }
}

class AppTableErrorState extends StatelessWidget {
  const AppTableErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppUtils.spacingLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppErrorBanner(message: message),
          const SizedBox(height: AppUtils.spacingMd),
          AppSecondaryButton(label: AppStrings.retry, onPressed: onRetry),
        ],
      ),
    );
  }
}
