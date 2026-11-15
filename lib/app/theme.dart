import 'package:flutter/material.dart';

/// Centralized Stark Group design system and Material 3 theme configuration.
///
/// Palette rules:
/// - Primary / Deep Blue (#0F2B48) and Corporate Blue (#1E5BB0) for core identity and actions.
/// - Light background (#F8FAFC) with pure white surfaces and subtle borders (#E2E8F0).
/// - Green (#16A34A) ONLY for active/success states.
/// - Red (#DC2626) ONLY for delete actions, errors, and destructive operations.
class AppTheme {
  AppTheme._();

  // --- Corporate Palette ---
  static const Color deepBlue = Color(0xFF0F2B48);
  static const Color corporateBlue = Color(0xFF1E5BB0);
  static const Color lightBlueHover = Color(0xFFF0F6FF);

  static const Color scaffoldBg = Color(0xFFF8FAFC);
  static const Color surfaceWhite = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF64748B);
  static const Color subtleBorder = Color(0xFFE2E8F0);

  // --- State colors ---
  // Green ONLY for active / success
  static const Color successGreen = Color(0xFF16A34A);
  static const Color successGreenBg = Color(0xFFECFDF5);
  static const Color successGreenBorder = Color(0xFFA7F3D0);

  // Red ONLY for delete / errors
  static const Color errorRed = Color(0xFFDC2626);
  static const Color errorRedBg = Color(0xFFFEF2F2);
  static const Color errorRedBorder = Color(0xFFFECACA);

  // Neutral / Maintenance
  static const Color neutralText = Color(0xFF475569);
  static const Color neutralBg = Color(0xFFF1F5F9);
  static const Color neutralBorder = Color(0xFFE2E8F0);

  static const Color maintenanceText = Color(0xFF0369A1);
  static const Color maintenanceBg = Color(0xFFF0F9FF);
  static const Color maintenanceBorder = Color(0xFFBAE6FD);

  /// Consistent page spacing
  static const double pagePadding = 24.0;
  static const double cardRadius = 10.0;
  static const double inputRadius = 8.0;

  /// Main application theme.
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: scaffoldBg,
        fontFamily: 'Segoe UI',
        colorScheme: const ColorScheme.light(
          primary: deepBlue,
          onPrimary: Colors.white,
          secondary: corporateBlue,
          onSecondary: Colors.white,
          surface: surfaceWhite,
          onSurface: textPrimary,
          error: errorRed,
          onError: Colors.white,
          outline: subtleBorder,
          outlineVariant: subtleBorder,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: surfaceWhite,
          foregroundColor: deepBlue,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: deepBlue,
          ),
          iconTheme: IconThemeData(color: deepBlue),
        ),
        cardTheme: CardThemeData(
          color: surfaceWhite,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius),
            side: const BorderSide(color: subtleBorder, width: 1),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceWhite,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
          hintStyle: const TextStyle(color: textMuted, fontSize: 14),
          prefixIconColor: textMuted,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(inputRadius),
            borderSide: const BorderSide(color: subtleBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(inputRadius),
            borderSide: const BorderSide(color: subtleBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(inputRadius),
            borderSide: const BorderSide(color: corporateBlue, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(inputRadius),
            borderSide: const BorderSide(color: errorRed, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(inputRadius),
            borderSide: const BorderSide(color: errorRed, width: 1.5),
          ),
          errorStyle: const TextStyle(color: errorRed, fontSize: 12),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: corporateBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(inputRadius),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: deepBlue,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            side: const BorderSide(color: subtleBorder, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(inputRadius),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        dataTableTheme: const DataTableThemeData(
          headingRowColor: WidgetStatePropertyAll(Color(0xFFF8FAFC)),
          headingTextStyle: TextStyle(
            fontWeight: FontWeight.w700,
            color: deepBlue,
            fontSize: 13,
            letterSpacing: 0.3,
          ),
          dataTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 13,
          ),
          dividerThickness: 1,
          horizontalMargin: 24,
          columnSpacing: 24,
        ),
        navigationRailTheme: const NavigationRailThemeData(
          backgroundColor: surfaceWhite,
          indicatorColor: corporateBlue,
          selectedIconTheme: IconThemeData(color: Colors.white),
          unselectedIconTheme: IconThemeData(color: textMuted),
          selectedLabelTextStyle: TextStyle(
            color: corporateBlue,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          unselectedLabelTextStyle: TextStyle(
            color: textMuted,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: surfaceWhite,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius),
            side: const BorderSide(color: subtleBorder),
          ),
        ),
      );
}
