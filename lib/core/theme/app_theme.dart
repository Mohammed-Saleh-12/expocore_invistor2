import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constant/appcolors.dart';

class AppTheme {
  static TextTheme get _cairoTextTheme => GoogleFonts.cairoTextTheme(
    const TextTheme(
      headlineLarge:  TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      titleLarge:     TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      titleMedium:    TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      bodyLarge:      TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall:      TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      labelSmall:     TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
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
