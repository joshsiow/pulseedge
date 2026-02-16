// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand-aligned palette (DO NOT change hex values)
  static const Color black = Color(0xFF000000);
  static const Color darkPrimary = Color(0xFF3A2B2C); // Deep charcoal-brown
  static const Color primary = Color(0xFF755659); // Main brand accent
  static const Color secondary = Color(0xFFA8898C); // Softer mid-tone
  static const Color surface = Color(0xFFD3C4C5); // Elevated surfaces, cards
  static const Color background = Color(0xFFFEFFFF); // Clean background
  static const Color macDarkBackground = Color(0xFF000000); // True black for macOS dark mode
  static const Color macDarkSurface = Color(0xFF1E1E1E); // Slightly elevated dark surface

  static const BorderRadius _borderRadius = BorderRadius.all(Radius.circular(12));
  //static const BorderRadius _pillRadius = BorderRadius.all(Radius.circular(28));

  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    canvasColor: background,
    colorScheme: ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: surface,
      background: background,
      error: Colors.red.shade600,
    ),
    textTheme: GoogleFonts.interTextTheme().apply(
      bodyColor: black,
      displayColor: black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: black,
      elevation: 0,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: _borderRadius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: _borderRadius,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: _borderRadius,
        borderSide: BorderSide(color: primary, width: 2),
      ),
      labelStyle: TextStyle(color: black, fontWeight: FontWeight.w600),
      hintStyle: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
      prefixIconColor: black,
      suffixIconColor: black,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: background,
        shape: const RoundedRectangleBorder(borderRadius: _borderRadius),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary),
        shape: const RoundedRectangleBorder(borderRadius: _borderRadius),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
      ),
    ),
    cardTheme: const CardThemeData( // Fixed: Use CardThemeData
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: _borderRadius),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: surface,
      contentTextStyle: TextStyle(color: black, fontWeight: FontWeight.w600),
      actionTextColor: primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: _borderRadius),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primary,
      linearTrackColor: secondary,
    ),
  );

  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: macDarkBackground,
    canvasColor: macDarkBackground,
    colorScheme: ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: macDarkSurface,
      background: macDarkBackground,
      error: Colors.red.shade400,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: macDarkSurface,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: macDarkSurface,
      border: OutlineInputBorder(
        borderRadius: _borderRadius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: _borderRadius,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: _borderRadius,
        borderSide: BorderSide(color: primary, width: 2),
      ),
      labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      hintStyle: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
      prefixIconColor: Colors.white,
      suffixIconColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: _borderRadius),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary),
        shape: const RoundedRectangleBorder(borderRadius: _borderRadius),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
      ),
    ),
    cardTheme: const CardThemeData( // Fixed: Use CardThemeData
      color: macDarkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: _borderRadius),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: macDarkSurface,
      contentTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      actionTextColor: primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: _borderRadius),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primary,
      linearTrackColor: secondary,
    ),
  );
}