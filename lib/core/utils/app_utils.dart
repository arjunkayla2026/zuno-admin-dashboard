import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/enums/app_status.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';

typedef StatusColors = ({Color background, Color foreground});

abstract final class AppUtils {
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static const double mobileBreakpoint = 600;
  static const double desktopBreakpoint = 1024;

  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 12;
  static const double spacingLg = 16;
  static const double spacingXl = 24;
  static const double spacingXxl = 32;

  static const EdgeInsets badgePadding = EdgeInsets.symmetric(
    horizontal: spacingMd,
    vertical: spacingXs,
  );

  static final BorderRadius radiusSmall = BorderRadius.circular(
    AppTheme.radiusSmall,
  );
  static final BorderRadius radiusMedium = BorderRadius.circular(
    AppTheme.radiusMedium,
  );
  static final BorderRadius radiusLarge = BorderRadius.circular(
    AppTheme.radiusLarge,
  );
  static const BorderRadius radiusPill = BorderRadius.all(Radius.circular(999));

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static bool isValidEmail(String email) =>
      _emailPattern.hasMatch(email.trim());

  static bool isMobile(BuildContext context) =>
      screenWidth(context) < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      !isMobile(context) && !isDesktop(context);

  static bool isDesktop(BuildContext context) =>
      screenWidth(context) >= desktopBreakpoint;

  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    if (isDesktop(context)) return desktop;
    if (isMobile(context)) return mobile;
    return tablet ?? desktop;
  }

  static EdgeInsets pagePadding(BuildContext context) => EdgeInsets.all(
    responsive(
      context,
      mobile: spacingLg,
      tablet: spacingXl,
      desktop: spacingXxl,
    ),
  );

  static StatusColors statusColors(BuildContext context, AppStatus status) {
    final colors = context.appColors;
    return switch (status) {
      AppStatus.active => (
        background: colors.activeBadge,
        foreground: colors.activeText,
      ),
      AppStatus.inactive => (
        background: colors.inactiveBadge,
        foreground: colors.inactiveText,
      ),
      AppStatus.isNew => (
        background: colors.newBadge,
        foreground: colors.newText,
      ),
      AppStatus.pending => (
        background: colors.pendingBadge,
        foreground: colors.pendingText,
      ),
      AppStatus.blocked || AppStatus.error => (
        background: colors.errorBadge,
        foreground: colors.errorText,
      ),
    };
  }

  static BoxDecoration gradientDecoration(
    Gradient gradient, {
    BorderRadius? borderRadius,
  }) => BoxDecoration(
    gradient: gradient,
    borderRadius: borderRadius ?? radiusMedium,
  );

  static BoxDecoration cardDecoration(BuildContext context) => BoxDecoration(
    color: context.colorScheme.surface,
    borderRadius: radiusLarge,
    boxShadow: AppColors.cardShadows,
  );

  static BoxDecoration statusBadgeDecoration(
    BuildContext context,
    AppStatus status,
  ) => BoxDecoration(
    color: statusColors(context, status).background,
    borderRadius: radiusPill,
  );

  static BoxDecoration uploadCardDecoration(BuildContext context) =>
      BoxDecoration(
        color: context.appColors.uploadBackground,
        borderRadius: radiusMedium,
        border: Border.all(color: context.appColors.uploadBorder),
      );

  static BoxDecoration selectedSubmoduleDecoration() => BoxDecoration(
    color: AppColors.submoduleSelectedBackground,
    borderRadius: radiusSmall,
  );

  static BoxDecoration paginationSelectedDecoration() => BoxDecoration(
    color: AppColors.paginationSelected,
    borderRadius: radiusSmall,
  );
}
