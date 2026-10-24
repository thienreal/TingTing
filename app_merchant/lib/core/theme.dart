/// File: theme.dart
/// Module: Core
/// Description: Định nghĩa toàn bộ bảng màu và ThemeData chuẩn cho TingTing Merchant App.
///   Đảm bảo không hardcode màu sắc ở bất kỳ file giao diện nào theo UI_Design_Rules.
///
/// Responsibility:
///   - Cung cấp AppColors chuẩn (Vàng #FAD240 cho Merchant B2B, Hồng #E8687D cho hành động)
///   - Cấu hình ThemeData (font Be Vietnam Pro, scaffold background, text theme, shadows)
///
/// Dependencies:
///   - package:flutter/material.dart
///
/// Todo:
///   - [ ] Thêm DarkTheme khi có yêu cầu thiết kế Dark Mode trong tương lai
library;

import 'package:flutter/material.dart';

// ==========================================
// COLOR PALETTE — BẢNG MÀU CHUẨN DỰ ÁN
// ==========================================

/// Toàn bộ mã màu sử dụng trong TingTing Merchant App.
/// Tuân thủ nghiêm ngặt theo docs/UI_Design_Rules.md.
class AppColors {
  // Màu thương hiệu chính (B2B Merchant dùng Vàng TingTing làm chủ đạo)
  static const Color primary = Color(0xFFFAD240); // Vàng TingTing
  static const Color primaryLight = Color(0xFFFFF7D6); // Vàng rất nhạt (background badge, highlight)
  static const Color primaryDark = Color(0xFFE5B800); // Vàng sẫm

  // Màu hành động chính
  static const Color action = Color(0xFFE8687D); // Hồng/Đỏ san hô (CTA, Cancel, Tag alert)
  static const Color actionLight = Color(0xFFFDE8EC); // Hồng nhạt nền badge

  // Nền & Bề mặt
  static const Color background = Color(0xFFF4F5F6); // Xám nhạt nền ứng dụng
  static const Color card = Color(0xFFFFFFFF); // Trắng nền thẻ / container
  static const Color inputBackground = Color(0xFFF5F6F8); // Xám nền input form

  // Màu chữ
  static const Color textPrimary = Color(0xFF1A1A1A); // Đen/Xám đậm (Tiêu đề, giá trị chính)
  static const Color textSecondary = Color(0xFF757575); // Xám vừa (Mô tả, phụ đề, thời gian)
  static const Color textMuted = Color(0xFFA0A0A0); // Xám nhạt (Placeholder, icon mờ)

  // Màu trạng thái & Tags
  static const Color success = Color(0xFF2E7D32); // Xanh lá thành công (+ điểm)
  static const Color successLight = Color(0xFFE8F5E9); // Nền xanh lá nhạt
  static const Color info = Color(0xFF1976D2); // Xanh dương thông tin
  static const Color infoLight = Color(0xFFE3F2FD); // Xanh dương nhạt
  static const Color warning = Color(0xFFF57C00); // Cam cảnh báo
  static const Color border = Color(0xFFE0E0E0); // Đường viền chuẩn

  // Đổ bóng chuẩn UI_Design_Rules: 0.05 opacity, blurRadius 10
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get bottomNavShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, -2),
    ),
  ];
}

// ==========================================
// APP THEME DATA
// ==========================================

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.action,
        surface: AppColors.card,
        error: AppColors.action,
      ),
      fontFamily: 'Be Vietnam Pro',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 28,
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w400,
          fontSize: 13,
        ),
        bodySmall: TextStyle(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w400,
          fontSize: 11,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          fontFamily: 'Be Vietnam Pro',
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
