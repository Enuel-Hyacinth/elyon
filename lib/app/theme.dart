import 'package:flutter/material.dart';

class ELyonTheme {
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color backgroundBlack = Color(0xFF121212);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color softGrey = Color(0xFFB0B0B0);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundBlack,
    primaryColor: primaryGold,
    colorScheme: const ColorScheme.dark(
      primary: primaryGold,
      secondary: primaryGold,
      surface: backgroundBlack,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundBlack,
      elevation: 0,
      centerTitle: true,
      foregroundColor: pureWhite,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: pureWhite,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: pureWhite,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: softGrey,
        fontSize: 14,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGold,
        foregroundColor: backgroundBlack,
        padding: const EdgeInsets.symmetric(
          horizontal: 28,
          vertical: 14,
        ),
      ),
    ),
  );
}
