import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFAD240); // Vàng
  static const Color action = Color(0xFFE8687D); // Hồng/Đỏ san hô
  static const Color background = Color(0xFFF4F5F6); // Xám nhạt
  static const Color card = Color(0xFFFFFFFF); // Trắng
  static const Color textPrimary = Color(0xFF1A1A1A); // Đen/Xám đậm
  static const Color textSecondary = Color(0xFF757575); // Xám nhạt
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.action,
        surface: AppColors.card,
      ),
      fontFamily: 'Be Vietnam Pro', // Can use Inter or Montserrat
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w400),
      ),
    );
  }
}
