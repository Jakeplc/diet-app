import 'package:flutter/material.dart';

class AppTheme {
  /// Warm, energetic light theme with deep orange accents
  static ThemeData light() {
    const seedColor = Color(0xFFFF6B35); // Deep Orange
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
      primary: const Color(0xFFFF6B35), // Deep Orange
      secondary: const Color(0xFF00BCD4), // Teal
      surface: const Color(0xFFFAFAFA),
      background: const Color(0xFFF5F5F5),
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
    );

    return base.copyWith(
      cardTheme: CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 6,
      ),
      appBarTheme: AppBarThemeData(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
    );
  }

  /// Dark theme with deep navy base and neon accents
  static ThemeData dark() {
    const seedColor = Color(0xFFFF6B35); // Deep Orange
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
      primary: const Color(0xFFFF6B35), // Deep Orange
      secondary: const Color(0xFF00E5FF), // Bright Cyan
      surface: const Color(0xFF1A1A2E), // Deep Navy
      background: const Color(0xFF0F0F1E), // Darker Navy
      surfaceVariant: const Color(0xFF2D2D44),
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
    );

    return base.copyWith(
      cardTheme: CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: const Color(0xFF1A1A2E),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: const Color(0xFF2D2D44),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 6,
      ),
      appBarTheme: const AppBarThemeData(
        elevation: 0,
        backgroundColor: Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF0F0F1E),
    );
  }
}
