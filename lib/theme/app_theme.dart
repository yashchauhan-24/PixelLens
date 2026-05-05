import 'package:flutter/material.dart';

class AppTheme {
  static const Color brown = Color(0xFF5A3E2B);
  static const Color darkBrown = Color(0xFF342116);
  static const Color cream = Color(0xFFF7F1E3);
  static const Color gold = Color(0xFFC59D5F);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: brown,
      brightness: Brightness.light,
      primary: brown,
      secondary: gold,
      surface: cream,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF8F3EA),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF8F3EA),
        foregroundColor: darkBrown,
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 10,
        shadowColor: Colors.brown.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brown,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: darkBrown),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: darkBrown),
        headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: darkBrown),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: darkBrown),
        bodyLarge: TextStyle(fontSize: 16, color: darkBrown),
        bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF6B5B4B)),
      ),
    );
  }
}
