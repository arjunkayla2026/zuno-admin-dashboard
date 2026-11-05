import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';

abstract final class AppTheme {
  static const double radiusField = 10;
  static const double radiusButton = 10;
  static const double radiusNavItem = 10;
  static const double radiusSmall = 12;
  static const double radiusCard = 14;
  static const double radiusTile = 16;
  static const double radiusMedium = 18;
  static const double radiusMenu = 20;
  static const double radiusLarge = 24;
  static const double buttonHeight = 50;

  static ThemeData get light => _build(
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.textPrimary,
      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.sidebarBackground,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.primaryLight,
      onSecondaryContainer: AppColors.primaryDark,
      tertiary: AppColors.success,
      onTertiary: AppColors.white,
      tertiaryContainer: AppColors.activeBadge,
      onTertiaryContainer: AppColors.activeText,
      error: AppColors.error,
      onError: AppColors.white,
      errorContainer: AppColors.errorBadge,
      onErrorContainer: AppColors.errorText,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textLabel,
      surfaceContainerLowest: AppColors.white,
      surfaceContainerLow: AppColors.background,
      surfaceContainer: AppColors.inactiveBadge,
      surfaceContainerHigh: AppColors.background,
      surfaceContainerHighest: AppColors.border,
      outline: AppColors.textHint,
      outlineVariant: AppColors.border,
      shadow: AppColors.black,
      scrim: AppColors.black,
      inverseSurface: AppColors.textPrimary,
      onInverseSurface: AppColors.white,
      inversePrimary: AppColors.primaryDark,
      surfaceTint: AppColors.transparent,
    ),
    scaffoldBackground: AppColors.background,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textTertiary: AppColors.textTertiary,
    textHint: AppColors.textHint,
    border: AppColors.border,
    overlayStyle: SystemUiOverlayStyle.dark,
    extension: AppThemeColors.light,
  );

  static ThemeData get dark => _build(
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.textPrimary,
      primaryContainer: AppColors.darkPrimaryContainer,
      onPrimaryContainer: AppColors.darkOnPrimaryContainer,
      secondary: AppColors.darkOnPrimaryContainer,
      onSecondary: AppColors.textPrimary,
      secondaryContainer: AppColors.darkPrimaryContainer,
      onSecondaryContainer: AppColors.darkOnPrimaryContainer,
      tertiary: AppColors.darkActiveText,
      onTertiary: AppColors.textPrimary,
      tertiaryContainer: AppColors.darkActiveBadge,
      onTertiaryContainer: AppColors.darkActiveText,
      error: AppColors.darkError,
      onError: AppColors.textPrimary,
      errorContainer: AppColors.darkErrorBadge,
      onErrorContainer: AppColors.darkErrorText,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      onSurfaceVariant: AppColors.darkTextSecondary,
      surfaceContainerLowest: AppColors.darkBackground,
      surfaceContainerLow: AppColors.darkBackground,
      surfaceContainer: AppColors.darkSurface,
      surfaceContainerHigh: AppColors.darkSurfaceHigh,
      surfaceContainerHighest: AppColors.darkSurfaceHigh,
      outline: AppColors.darkTextHint,
      outlineVariant: AppColors.darkBorder,
      shadow: AppColors.black,
      scrim: AppColors.black,
      inverseSurface: AppColors.darkTextPrimary,
      onInverseSurface: AppColors.textPrimary,
      inversePrimary: AppColors.primaryDark,
      surfaceTint: AppColors.transparent,
    ),
    scaffoldBackground: AppColors.darkBackground,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    textTertiary: AppColors.darkTextTertiary,
    textHint: AppColors.darkTextHint,
    border: AppColors.darkBorder,
    overlayStyle: SystemUiOverlayStyle.light,
    extension: AppThemeColors.dark,
  );

  static ThemeData _build({
    required ColorScheme colorScheme,
    required Color scaffoldBackground,
    required Color textPrimary,
    required Color textSecondary,
    required Color textTertiary,
    required Color textHint,
    required Color border,
    required SystemUiOverlayStyle overlayStyle,
    required AppThemeColors extension,
  }) {
    final textTheme = AppTextStyles.textTheme.apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusButton),
    );
    const buttonMinSize = Size(0, buttonHeight);
    const buttonPadding = EdgeInsets.symmetric(horizontal: 24);

    OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusField),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      canvasColor: scaffoldBackground,
      fontFamily: AppTextStyles.dmSans,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      dividerColor: border,
      extensions: [extension],

      // App bar --------------------------------------------------------------
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: textPrimary,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        systemOverlayStyle: overlayStyle,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: textPrimary, size: 24),
        actionsIconTheme: IconThemeData(color: textPrimary, size: 24),
      ),

      // Buttons --------------------------------------------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(buttonMinSize),
          padding: const WidgetStatePropertyAll(buttonPadding),
          shape: WidgetStatePropertyAll(buttonShape),
          textStyle: WidgetStatePropertyAll(AppTextStyles.labelLarge),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.primary,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? AppColors.onPrimaryButton.withValues(alpha: 0.5)
                : AppColors.onPrimaryButton,
          ),
          iconSize: const WidgetStatePropertyAll(16),
          overlayColor: WidgetStatePropertyAll(
            AppColors.onPrimaryButton.withValues(alpha: 0.08),
          ),
          elevation: const WidgetStatePropertyAll(0),
          surfaceTintColor: const WidgetStatePropertyAll(AppColors.transparent),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonMinSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: AppTextStyles.labelLarge,
          backgroundColor: extension.primarySoft,
          foregroundColor: extension.onPrimarySoft,
          disabledBackgroundColor: extension.primarySoft.withValues(alpha: 0.5),
          disabledForegroundColor: textHint,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonMinSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: AppTextStyles.labelLarge,
          foregroundColor: textPrimary,
          disabledForegroundColor: textHint,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.brightness == Brightness.light
              ? AppColors.primaryDark
              : AppColors.primary,
          disabledForegroundColor: textHint,
          textStyle: AppTextStyles.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: textPrimary,
          disabledForegroundColor: textHint,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        elevation: 6,
        highlightElevation: 2,
        shape: const CircleBorder(),
        iconSize: 28,
      ),

      // Inputs ---------------------------------------------------------------
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: colorScheme.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 14,
        ),
        hintStyle: AppTextStyles.bodySmall.copyWith(
          color: extension.formFieldHint,
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: textSecondary),
        floatingLabelStyle: AppTextStyles.bodySmall.copyWith(
          color: textSecondary,
        ),
        helperStyle: AppTextStyles.bodySmall.copyWith(color: textTertiary),
        errorStyle: AppTextStyles.bodySmall.copyWith(color: colorScheme.error),
        prefixIconColor: textTertiary,
        suffixIconColor: textTertiary,
        border: inputBorder(extension.formFieldBorder),
        enabledBorder: inputBorder(extension.formFieldBorder),
        focusedBorder: inputBorder(AppColors.primary, 1.5),
        errorBorder: inputBorder(colorScheme.error),
        focusedErrorBorder: inputBorder(colorScheme.error, 1.5),
        disabledBorder: inputBorder(border.withValues(alpha: 0.5)),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primary.withValues(alpha: 0.3),
        selectionHandleColor: AppColors.primary,
      ),

      // Surfaces -------------------------------------------------------------
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: AppColors.transparent,
        iconColor: textSecondary,
        textColor: textPrimary,
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: textSecondary,
        ),
        leadingAndTrailingTextStyle: AppTextStyles.labelMedium.copyWith(
          color: textTertiary,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        textStyle: AppTextStyles.labelSmall.copyWith(
          color: colorScheme.onInverseSurface,
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(colorScheme.outline),
        thickness: const WidgetStatePropertyAll(6),
        radius: const Radius.circular(radiusSmall),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: textSecondary,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        modalBackgroundColor: colorScheme.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        showDragHandle: true,
        dragHandleColor: border,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusLarge),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        actionTextColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surface,
        surfaceTintColor: AppColors.transparent,
        textStyle: AppTextStyles.bodyMedium.copyWith(color: textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),

      // Navigation -----------------------------------------------------------
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: textTertiary,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedLabelStyle: AppTextStyles.labelSmall,
        unselectedLabelStyle: AppTextStyles.labelSmall,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        indicatorColor: AppColors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 26,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : textTertiary,
          ),
        ),
        labelTextStyle: WidgetStatePropertyAll(AppTextStyles.labelSmall),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: textPrimary,
        unselectedLabelColor: textTertiary,
        labelStyle: AppTextStyles.labelLarge,
        unselectedLabelStyle: AppTextStyles.labelLarge,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.transparent,
      ),

      // Indicators & badges --------------------------------------------------
      badgeTheme: BadgeThemeData(
        backgroundColor: AppColors.primary,
        textColor: AppColors.textPrimary,
        textStyle: AppTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        smallSize: 8,
        largeSize: 22,
        padding: const EdgeInsets.symmetric(horizontal: 6),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: extension.primarySoft,
        selectedColor: AppColors.primary,
        disabledColor: extension.inactiveBadge,
        labelStyle: AppTextStyles.labelMedium.copyWith(color: textPrimary),
        secondaryLabelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: const StadiumBorder(),
        checkmarkColor: AppColors.textPrimary,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: extension.primarySoft,
        circularTrackColor: AppColors.transparent,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll(AppColors.textPrimary),
        side: BorderSide(color: textHint, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : textHint,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.white
              : textHint,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : colorScheme.surfaceContainer,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(AppColors.transparent),
      ),
      iconTheme: IconThemeData(color: textPrimary, size: 24),
    );
  }
}
