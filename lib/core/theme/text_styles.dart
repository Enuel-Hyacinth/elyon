import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle headline = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.pureWhite,
  );

  static const TextStyle title = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.pureWhite,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.pureWhite,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14,
    color: AppColors.softGrey,
  );
}