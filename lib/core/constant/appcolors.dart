import 'package:flutter/material.dart';

class AppColors {
  static const Color darkBg         = Color(0xFF1D1A39);
  static const Color darkCard       = Color(0xFF2A2640);
  static const Color darkSurface    = Color(0xFF332E50);
  static const Color darkPrimary    = Color(0xFF7A1FFF);
  static const Color darkSecondary  = Color(0xFFFF1592);
  static const Color darkAccent     = Color(0xFFFF6A00);
  static const Color darkPink       = Color(0xFFFFD1FF);

  static const Color lightBg        = Color(0xFFF5F5F7);
  static const Color lightCard      = Color(0xFFFFFFFF);
  static const Color lightSurface   = Color(0xFFEEEEF5);
  static const Color lightPrimary   = Color(0xFF451952);
  static const Color lightSecondary = Color(0xFF662549);
  static const Color lightAccent    = Color(0xFFF7941D);
  static const Color lightPink      = Color(0xFFE8BCB9);

  static const Color orange  = Color(0xFFF7941D);
  static const Color success = Color(0xFF4CAF50);
  static const Color info    = Color(0xFF2196F3);
  static const Color grey    = Color(0xFF888888);
  static const Color white   = Color(0xFFFFFFFF);
  static const Color black   = Color(0xFF000000);
  static const Color error   = Color(0xFFE53935);

  static const LinearGradient darkCTAGradient = LinearGradient(
    colors: [Color(0xFF7A1FFF), Color(0xFFFF6A00)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient lightCTAGradient = LinearGradient(
    colors: [Color(0xFF451952), Color(0xFFF7941D)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF2A2640), Color(0xFF332E50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient favoriteGradient = LinearGradient(
    colors: [Color(0xFFFF1592), Color(0xFFFF6A00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF1D1A39), Color(0xFF332E50)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
