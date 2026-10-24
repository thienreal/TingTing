/// File: primary_button.dart
/// Module: SharedWidgets
/// Description: Nút CTA chính của User App (Đổi ngay, Tiếp tục...).
///   Trải dài toàn màn hình, neo ở dưới cùng, màu Hồng/Đỏ san hô theo UI_Design_Rules.
///
/// Responsibility:
///   - Cung cấp widget nút bấm tái sử dụng cho toàn bộ User App.
///   - Tuân thủ UI_Design_Rules: bo góc 12px, màu action (#E8687D), chữ trắng SemiBold
///   - Hỗ trợ trạng thái isLoading hiển thị CircularProgressIndicator
///
/// Dependencies:
///   - app_user/lib/core/theme.dart (AppColors)
///
/// Todo:
///   (File đã hoàn thiện)
library;

import 'package:flutter/material.dart';
import '../core/theme.dart';

// ==========================================
// PRIMARY BUTTON — WIDGET CHÍNH
// ==========================================

class PrimaryButton extends StatelessWidget {
  /// Nhãn hiển thị trên nút (bắt buộc).
  final String label;

  /// Callback khi người dùng nhấn nút.
  /// Nếu null hoặc isLoading = true, nút ở trạng thái disabled.
  final VoidCallback? onPressed;

  /// Icon hiển thị bên trái nhãn (tuỳ chọn).
  final IconData? prefixIcon;

  /// Trạng thái đang xử lý (loading)
  final bool isLoading;

  /// Màu nền tùy chỉnh (mặc định là AppColors.action)
  final Color? backgroundColor;

  /// Màu chữ / icon (mặc định là Colors.white)
  final Color? foregroundColor;

  /// Chiều cao của nút (mặc định là 52px)
  final double height;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.prefixIcon,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.action;
    final fgColor = foregroundColor ?? Colors.white;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          disabledBackgroundColor: bgColor.withOpacity(0.4),
          foregroundColor: fgColor,
          disabledForegroundColor: fgColor.withOpacity(0.8),
          // Bo góc 12px theo UI_Design_Rules §Shapes & Layout
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (prefixIcon != null) ...[
                    Icon(prefixIcon, size: 20, color: fgColor),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: fgColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
