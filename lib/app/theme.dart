import 'package:flutter/material.dart';

/// Centralized Material 3 theme configuration for the VMS app.
///
/// Usage in main.dart:
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark,
class AppTheme {
  // Prevent instantiation — this is a utility class.
  AppTheme._();

  // Brand seed color — a professional blue.
  static const Color _seedColor = Color(0xFF1565C0);

  /// Light theme for the application.
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
        ),
      );

  /// Dark theme for the application.
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
        ),
      );
}

