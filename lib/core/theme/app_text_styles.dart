import 'package:flutter/material.dart';

abstract final class AppTextStyles {
  static const String poppins = 'Poppins';
  static const String dmSans = 'DM Sans';
  static const String jetBrainsMono = 'JetBrains Mono';
  static const String arial = 'Arial';
  static const String courierNew = 'Courier New';

  static const TextStyle splashHeading = TextStyle(
    fontFamily: poppins,
    fontSize: 46,
    fontWeight: FontWeight.w600,
    height: 51.52 / 46,
    letterSpacing: -0.8,
  );

  static const TextStyle sectionHeading = TextStyle(
    fontFamily: poppins,
    fontSize: 28,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle pageTitle = TextStyle(
    fontFamily: poppins,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 24 / 20,
  );

  static const TextStyle sectionLabel = TextStyle(
    fontFamily: dmSans,
    fontSize: 11.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
  );

  static const TextStyle mono = TextStyle(
    fontFamily: jetBrainsMono,
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.2,
  );

  static const TextStyle monoSmall = TextStyle(
    fontFamily: jetBrainsMono,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.2,
  );

  static const TextStyle emphasisArial = TextStyle(
    fontFamily: arial,
    fontSize: 20.89,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle displayCourier = TextStyle(
    fontFamily: courierNew,
    fontSize: 34.82,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle displayLarge = splashHeading;

  static const TextStyle displayMedium = TextStyle(
    fontFamily: poppins,
    fontSize: 34,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: poppins,
    fontSize: 30,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle headlineLarge = sectionHeading;

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: poppins,
    fontSize: 26,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: poppins,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle titleLarge = pageTitle;

  static const TextStyle titleMedium = TextStyle(
    fontFamily: poppins,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: poppins,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: dmSans,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 25.6 / 16,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: dmSans,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: dmSans,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle alertMessage = TextStyle(
    fontFamily: dmSans,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.6,
  );

  static const TextStyle fieldValue = TextStyle(
    fontFamily: dmSans,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle captionSmall = TextStyle(
    fontFamily: dmSans,
    fontSize: 11.5,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle tableCell = TextStyle(
    fontFamily: dmSans,
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle tableFootnote = TextStyle(
    fontFamily: dmSans,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle compactButton = TextStyle(
    fontFamily: dmSans,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle menuItem = TextStyle(
    fontFamily: poppins,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle cardTitle = TextStyle(
    fontFamily: poppins,
    fontSize: 14.5,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle profileName = TextStyle(
    fontFamily: poppins,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle statValue = TextStyle(
    fontFamily: poppins,
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: dmSans,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: dmSans,
    fontSize: 13.5,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: dmSans,
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
  );

  static const TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
