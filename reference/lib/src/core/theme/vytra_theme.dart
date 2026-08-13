import 'package:flutter/material.dart';

/// Tokens from 04_DESIGN_SYSTEM.md. Do not generate a Material 3 tonal palette.
class VytraColor {
  static const bg = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF0F172A);
  static const inkMuted = Color(0xFF475467);
  static const line = Color(0xFFE4E7EC);
  static const forest = Color(0xFF0E2A1C);
  static const pulse = Color(0xFF6CA532);
  static const brand = Color(0xFF0E2A1C);
  static const brandInk = Color(0xFFFFFFFF);
  static const brandSoft = Color(0xFFE8F3DC);
  static const riskHigh = Color(0xFFB42318);
  static const riskModerate = Color(0xFFB54708);
  static const riskLow = Color(0xFF027A48);
  static const riskUnable = Color(0xFF475467);
}

ThemeData vytraTheme() {
  const text = TextTheme(
    displaySmall: TextStyle(fontSize: 28, height: 34 / 28, fontWeight: FontWeight.w600, color: VytraColor.ink),
    titleLarge: TextStyle(fontSize: 22, height: 28 / 22, fontWeight: FontWeight.w600, color: VytraColor.ink),
    titleMedium: TextStyle(fontSize: 18, height: 24 / 18, fontWeight: FontWeight.w600, color: VytraColor.ink),
    bodyLarge: TextStyle(fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w400, color: VytraColor.ink),
    bodyMedium: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400, color: VytraColor.inkMuted),
    labelLarge: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, color: VytraColor.ink),
  );
  return ThemeData(
    useMaterial3: false,
    fontFamily: 'NotoSans',
    scaffoldBackgroundColor: VytraColor.bg,
    colorScheme: const ColorScheme.light(
      primary: VytraColor.brand,
      onPrimary: VytraColor.brandInk,
      surface: VytraColor.surface,
      onSurface: VytraColor.ink,
    ),
    textTheme: text,
    appBarTheme: const AppBarTheme(
      backgroundColor: VytraColor.bg,
      foregroundColor: VytraColor.ink,
      elevation: 0,
    ),
  );
}
