import 'package:flutter/material.dart';
import 'appcolors.dart';

class AppTheme {
  static const String _fontFamily = 'Cairo';

  static TextTheme get _cairoTextTheme => const TextTheme(
    headlineLarge:  TextStyle(fontFamily: _fontFamily, fontSize: 28, fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(fontFamily: _fontFamily, fontSize: 22, fontWeight: FontWeight.w600),
    titleLarge:     TextStyle(fontFamily: _fontFamily, fontSize: 18, fontWeight: FontWeight.w600),
    titleMedium:    TextStyle(fontFamily: _fontFamily, fontSize: 16, fontWeight: FontWeight.w500),
    bodyLarge:      TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall:      TextStyle(fontFamily: _fontFamily, fontSize: 12, fontWeight: FontWeight.w400),
    labelSmall:     TextStyle(fontFamily: _fontFamily, fontSize: 10, fontWeight: FontWeight.w500),
  );

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    fontFamily: _fontFamily,
    scaffoldBackgroundColor: AppColors.darkBg,
    cardColor: AppColors.darkCard,
    colorScheme: const ColorScheme.dark(
      primary:    AppColors.darkPrimary,
      secondary:  AppColors.darkSecondary,
      tertiary:   AppColors.darkAccent,
      surface:    AppColors.darkCard,
      error:      AppColors.error,
    ),
    textTheme: _cairoTextTheme.apply(
      bodyColor:       AppColors.white,
      displayColor:    AppColors.white,
    ),
    iconTheme: const IconThemeData(color: AppColors.white),
    dividerColor: AppColors.darkSurface,
    useMaterial3: true,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.darkSurface),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.darkPrimary),
      ),
    ),
  );

  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    fontFamily: _fontFamily,
    scaffoldBackgroundColor: AppColors.lightBg,
    cardColor: AppColors.lightCard,
    colorScheme: const ColorScheme.light(
      primary:   AppColors.lightPrimary,
      secondary: AppColors.lightSecondary,
      tertiary:  AppColors.lightAccent,
      surface:   AppColors.lightCard,
      error:     AppColors.error,
    ),
    textTheme: _cairoTextTheme.apply(
      bodyColor:    AppColors.black,
      displayColor: AppColors.black,
    ),
    iconTheme: const IconThemeData(color: AppColors.lightPrimary),
    dividerColor: AppColors.lightSurface,
    useMaterial3: true,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.lightSurface),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.lightPrimary),
      ),
    ),
  );
}
