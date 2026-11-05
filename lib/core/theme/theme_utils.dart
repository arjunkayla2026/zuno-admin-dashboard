import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';

@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.textSecondary,
    required this.textTertiary,
    required this.primarySoft,
    required this.onPrimarySoft,
    required this.pendingBadge,
    required this.pendingText,
    required this.activeBadge,
    required this.activeText,
    required this.inactiveBadge,
    required this.inactiveText,
    required this.newBadge,
    required this.newText,
    required this.errorBadge,
    required this.errorText,
    required this.aadhaarUploaded,
    required this.pageBackground,
    required this.formFieldBorder,
    required this.formFieldReadOnly,
    required this.formFieldHint,
    required this.formFieldPlaceholder,
    required this.formDescription,
    required this.uploadBackground,
    required this.uploadBorder,
    required this.uploadIconBackground,
    required this.uploadedBackground,
  });

  final Color textSecondary;
  final Color textTertiary;
  final Color primarySoft;
  final Color onPrimarySoft;
  final Color pendingBadge;
  final Color pendingText;
  final Color activeBadge;
  final Color activeText;
  final Color inactiveBadge;
  final Color inactiveText;
  final Color newBadge;
  final Color newText;
  final Color errorBadge;
  final Color errorText;
  final Color aadhaarUploaded;
  final Color pageBackground;
  final Color formFieldBorder;
  final Color formFieldReadOnly;
  final Color formFieldHint;
  final Color formFieldPlaceholder;
  final Color formDescription;
  final Color uploadBackground;
  final Color uploadBorder;
  final Color uploadIconBackground;
  final Color uploadedBackground;

  static const AppThemeColors light = AppThemeColors(
    textSecondary: AppColors.textSecondary,
    textTertiary: AppColors.textTertiary,
    primarySoft: AppColors.primaryLight,
    onPrimarySoft: AppColors.primaryDark,
    pendingBadge: AppColors.pendingBadge,
    pendingText: AppColors.pendingText,
    activeBadge: AppColors.activeBadge,
    activeText: AppColors.activeText,
    inactiveBadge: AppColors.inactiveBadge,
    inactiveText: AppColors.inactiveText,
    newBadge: AppColors.newBadge,
    newText: AppColors.newText,
    errorBadge: AppColors.errorBadge,
    errorText: AppColors.errorText,
    aadhaarUploaded: AppColors.aadhaarUploaded,
    pageBackground: AppColors.background,
    formFieldBorder: AppColors.formFieldBorder,
    formFieldReadOnly: AppColors.formFieldReadOnly,
    formFieldHint: AppColors.formFieldHint,
    formFieldPlaceholder: AppColors.formFieldPlaceholder,
    formDescription: AppColors.formDescription,
    uploadBackground: AppColors.uploadBackground,
    uploadBorder: AppColors.uploadBorder,
    uploadIconBackground: AppColors.uploadIconBackground,
    uploadedBackground: AppColors.uploadedBackground,
  );

  static const AppThemeColors dark = AppThemeColors(
    textSecondary: AppColors.darkTextSecondary,
    textTertiary: AppColors.darkTextTertiary,
    primarySoft: AppColors.darkPrimaryContainer,
    onPrimarySoft: AppColors.darkOnPrimaryContainer,
    pendingBadge: AppColors.darkPendingBadge,
    pendingText: AppColors.darkPendingText,
    activeBadge: AppColors.darkActiveBadge,
    activeText: AppColors.darkActiveText,
    inactiveBadge: AppColors.darkInactiveBadge,
    inactiveText: AppColors.darkInactiveText,
    newBadge: AppColors.darkNewBadge,
    newText: AppColors.darkNewText,
    errorBadge: AppColors.darkErrorBadge,
    errorText: AppColors.darkErrorText,
    aadhaarUploaded: AppColors.darkAadhaarUploaded,
    pageBackground: AppColors.darkBackground,
    formFieldBorder: AppColors.darkBorder,
    formFieldReadOnly: AppColors.darkSurfaceHigh,
    formFieldHint: AppColors.darkTextTertiary,
    formFieldPlaceholder: AppColors.darkTextHint,
    formDescription: AppColors.darkTextSecondary,
    uploadBackground: AppColors.darkUploadBackground,
    uploadBorder: AppColors.darkOnPrimaryContainer,
    uploadIconBackground: AppColors.darkPrimaryContainer,
    uploadedBackground: AppColors.darkActiveBadge,
  );

  @override
  AppThemeColors copyWith({
    Color? textSecondary,
    Color? textTertiary,
    Color? primarySoft,
    Color? onPrimarySoft,
    Color? pendingBadge,
    Color? pendingText,
    Color? activeBadge,
    Color? activeText,
    Color? inactiveBadge,
    Color? inactiveText,
    Color? newBadge,
    Color? newText,
    Color? errorBadge,
    Color? errorText,
    Color? aadhaarUploaded,
    Color? pageBackground,
    Color? formFieldBorder,
    Color? formFieldReadOnly,
    Color? formFieldHint,
    Color? formFieldPlaceholder,
    Color? formDescription,
    Color? uploadBackground,
    Color? uploadBorder,
    Color? uploadIconBackground,
    Color? uploadedBackground,
  }) {
    return AppThemeColors(
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      primarySoft: primarySoft ?? this.primarySoft,
      onPrimarySoft: onPrimarySoft ?? this.onPrimarySoft,
      pendingBadge: pendingBadge ?? this.pendingBadge,
      pendingText: pendingText ?? this.pendingText,
      activeBadge: activeBadge ?? this.activeBadge,
      activeText: activeText ?? this.activeText,
      inactiveBadge: inactiveBadge ?? this.inactiveBadge,
      inactiveText: inactiveText ?? this.inactiveText,
      newBadge: newBadge ?? this.newBadge,
      newText: newText ?? this.newText,
      errorBadge: errorBadge ?? this.errorBadge,
      errorText: errorText ?? this.errorText,
      aadhaarUploaded: aadhaarUploaded ?? this.aadhaarUploaded,
      pageBackground: pageBackground ?? this.pageBackground,
      formFieldBorder: formFieldBorder ?? this.formFieldBorder,
      formFieldReadOnly: formFieldReadOnly ?? this.formFieldReadOnly,
      formFieldHint: formFieldHint ?? this.formFieldHint,
      formFieldPlaceholder: formFieldPlaceholder ?? this.formFieldPlaceholder,
      formDescription: formDescription ?? this.formDescription,
      uploadBackground: uploadBackground ?? this.uploadBackground,
      uploadBorder: uploadBorder ?? this.uploadBorder,
      uploadIconBackground: uploadIconBackground ?? this.uploadIconBackground,
      uploadedBackground: uploadedBackground ?? this.uploadedBackground,
    );
  }

  @override
  AppThemeColors lerp(covariant AppThemeColors? other, double t) {
    if (other == null) return this;
    return AppThemeColors(
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      onPrimarySoft: Color.lerp(onPrimarySoft, other.onPrimarySoft, t)!,
      pendingBadge: Color.lerp(pendingBadge, other.pendingBadge, t)!,
      pendingText: Color.lerp(pendingText, other.pendingText, t)!,
      activeBadge: Color.lerp(activeBadge, other.activeBadge, t)!,
      activeText: Color.lerp(activeText, other.activeText, t)!,
      inactiveBadge: Color.lerp(inactiveBadge, other.inactiveBadge, t)!,
      inactiveText: Color.lerp(inactiveText, other.inactiveText, t)!,
      newBadge: Color.lerp(newBadge, other.newBadge, t)!,
      newText: Color.lerp(newText, other.newText, t)!,
      errorBadge: Color.lerp(errorBadge, other.errorBadge, t)!,
      errorText: Color.lerp(errorText, other.errorText, t)!,
      aadhaarUploaded: Color.lerp(aadhaarUploaded, other.aadhaarUploaded, t)!,
      pageBackground: Color.lerp(pageBackground, other.pageBackground, t)!,
      formFieldBorder: Color.lerp(formFieldBorder, other.formFieldBorder, t)!,
      formFieldReadOnly: Color.lerp(
        formFieldReadOnly,
        other.formFieldReadOnly,
        t,
      )!,
      formFieldHint: Color.lerp(formFieldHint, other.formFieldHint, t)!,
      formFieldPlaceholder: Color.lerp(
        formFieldPlaceholder,
        other.formFieldPlaceholder,
        t,
      )!,
      formDescription: Color.lerp(formDescription, other.formDescription, t)!,
      uploadBackground: Color.lerp(
        uploadBackground,
        other.uploadBackground,
        t,
      )!,
      uploadBorder: Color.lerp(uploadBorder, other.uploadBorder, t)!,
      uploadIconBackground: Color.lerp(
        uploadIconBackground,
        other.uploadIconBackground,
        t,
      )!,
      uploadedBackground: Color.lerp(
        uploadedBackground,
        other.uploadedBackground,
        t,
      )!,
    );
  }
}

extension ThemeUtils on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  AppThemeColors get appColors =>
      Theme.of(this).extension<AppThemeColors>() ?? AppThemeColors.light;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  SystemUiOverlayStyle get pageOverlayStyle =>
      (isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
            systemNavigationBarColor: theme.scaffoldBackgroundColor,
            systemNavigationBarIconBrightness: isDarkMode
                ? Brightness.light
                : Brightness.dark,
          );
}
