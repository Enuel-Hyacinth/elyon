import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      scaffoldBackgroundColor: AppColors.backgroundBlack,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryGold,
        secondary: AppColors.primaryGold,
        surface: AppColors.card,
        error: AppColors.error,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundBlack,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.pureWhite,
      ),

      textTheme: const TextTheme(
        headlineLarge: AppTextStyles.headline,
        titleLarge: AppTextStyles.title,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.caption,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          foregroundColor: AppColors.backgroundBlack,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      cardColor: AppColors.card,
      dividerColor: AppColors.divider,
    );
  }
}