import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFFFDC903);
  static const Color primaryLight = Color(0xFFFFF7D6);
  static const Color primaryDark = Color(0xFF8A6A00);
  static const Color onPrimaryButton = Color(0xFF4A2200);

  static const Color sidebarBackground = Color(0xFF17243A);
  static const Color sidebarIconSelected = Color(0xFF4A2200);
  static const Color sidebarIconUnselected = Color(0xFFC3CAD6);
  static const Color sidebarTextUnselected = sidebarIconUnselected;
  static const Color phoneIcon = sidebarIconSelected;

  static const Color submoduleSelectedBackground = Color(0x21FDC903);
  static const Color submoduleSelectedText = primary;

  static const Color paginationSelected = sidebarBackground;
  static const Color reviewText = sidebarIconSelected;
  static const Color approveButton = activeText;

  static const Color activeBadge = Color(0xFFE2F3E9);
  static const Color activeText = Color(0xFF15804A);

  static const Color inactiveBadge = Color(0xFFEDECE7);
  static const Color inactiveText = Color(0xFF5E6472);

  static const Color newBadge = Color(0xFFE4ECFA);
  static const Color newText = Color(0xFF2A5DB5);

  static const Color pendingBadge = Color(0xFFFFF0D6);
  static const Color pendingText = Color(0xFFA86200);

  static const Color errorBadge = Color(0xFFFBE5E5);
  static const Color errorText = Color(0xFFC3343A);

  static const Color error = errorText;
  static const Color success = activeText;

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  static const Color background = Color(0xFFF5F4EF);
  static const Color surface = white;

  static const Color textPrimary = Color(0xFF17243A);
  static const Color textLabel = Color(0xFF737785);
  static const Color textSecondary = textLabel;
  static const Color textTertiary = Color(0xFF8A94A6);
  static const Color textHint = Color(0xFFA9B0BD);

  static const Color border = Color(0xFFECEDF0);

  static const Color formFieldBorder = Color(0xFFE7E3D9);
  static const Color cardBorder = formFieldBorder;
  static const Color statTileBackground = background;
  static const Color tableHeaderBackground = Color(0xFFFAF9F5);
  static const Color sidebarDivider = Color(0x1FFFFFFF);

  static const Color avatarBlue = newText;
  static const Color avatarRed = errorText;
  static const Color avatarGreen = activeText;
  static const Color avatarMagenta = Color(0xFFB03A79);
  static const Color avatarNavy = sidebarBackground;
  static const Color avatarPurple = Color(0xFF7A4BC2);
  static const Color avatarAmber = pendingText;
  static const Color avatarTeal = Color(0xFF0E7C86);
  static const Color avatarGray = inactiveText;

  static const List<Color> avatarPalette = [
    avatarBlue,
    avatarPurple,
    avatarGreen,
    avatarRed,
    avatarAmber,
    avatarTeal,
    avatarGray,
    avatarMagenta,
  ];

  static const Color modalScrim = Color(0x6B0D1624);
  static const Color menuText = Color(0xFF202020);
  static const Color tableActionIcon = Color(0xFF64748B);
  static const Color tableMutedText = Color(0xFFAEB1BA);
  static const Color formFieldReadOnly = Color(0xFFF4F6F9);
  static const Color formFieldHint = Color(0xFF757575);
  static const Color formFieldPlaceholder = Color(0xFF9A9CA8);
  static const Color formDescription = Color(0xFF6B6E7E);

  static const Color uploadBackground = Color(0xFFFBF7EC);
  static const Color uploadBorder = Color(0xFFF1DFA8);
  static const Color uploadIconBackground = Color(0xFFFFEFB1);
  static const Color uploadedBackground = Color(0xFFF3FBF3);
  static const Color aadhaarUploaded = Color(0xFFBFE3BF);

  static const Color navyGradientStart = sidebarBackground;
  static const Color navyGradientEnd = Color(0xFF2E4A7A);
  static const Color brownGradientStart = Color(0xFF632900);
  static const Color brownGradientEnd = Color(0xFFA9561A);
  static const Color tealGradientStart = Color(0xFF0E5C66);
  static const Color tealGradientEnd = sidebarBackground;

  static const Color cardShadow = Color(0x0F17243A);
  static const Color popoverShadow = Color(0x241F2430);
  static const Color menuShadow = Color(0x2E0D1624);

  static const Color darkBackground = Color(0xFF111318);
  static const Color darkSurface = Color(0xFF1B1E25);
  static const Color darkSurfaceHigh = Color(0xFF252932);
  static const Color darkTextPrimary = Color(0xFFF2F3F5);
  static const Color darkTextSecondary = Color(0xFFAAB3C5);
  static const Color darkTextTertiary = Color(0xFF7D879A);
  static const Color darkTextHint = Color(0xFF5E6676);
  static const Color darkBorder = Color(0xFF2E333D);

  static const Color darkPrimaryContainer = Color(0xFF3A3000);
  static const Color darkOnPrimaryContainer = Color(0xFFFFE27A);

  static const Color darkActiveBadge = Color(0xFF1C3320);
  static const Color darkActiveText = Color(0xFF5BD06B);
  static const Color darkInactiveBadge = Color(0xFF2A2E36);
  static const Color darkInactiveText = Color(0xFF9AA2B1);
  static const Color darkNewBadge = Color(0xFF1C2A44);
  static const Color darkNewText = Color(0xFF8FB4F0);
  static const Color darkPendingBadge = Color(0xFF3A2A12);
  static const Color darkPendingText = Color(0xFFFFB04D);
  static const Color darkErrorBadge = Color(0xFF3A1E20);
  static const Color darkErrorText = Color(0xFFFF6B6F);
  static const Color darkError = darkErrorText;

  static const Color darkUploadBackground = Color(0x29FDC903);
  static const Color darkAadhaarUploaded = Color(0xFF2D4A2D);

  static const LinearGradient navyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navyGradientStart, navyGradientEnd],
  );

  static const LinearGradient brownGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brownGradientStart, brownGradientEnd],
  );

  static const LinearGradient tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tealGradientStart, tealGradientEnd],
  );

  static const List<BoxShadow> cardShadows = [
    BoxShadow(color: cardShadow, offset: Offset(0, 2), blurRadius: 12),
  ];

  static const List<BoxShadow> menuShadows = [
    BoxShadow(color: menuShadow, offset: Offset(0, 12), blurRadius: 40),
  ];

  static const List<BoxShadow> popoverShadows = [
    BoxShadow(color: popoverShadow, offset: Offset(0, 8), blurRadius: 24),
  ];
}
