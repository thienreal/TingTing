/// File: primary_button.dart
/// Module: SharedWidgets
/// Description: Nút CTA chính của User App (Đổi ngay, Tiếp tục...).
///   Trải dài toàn màn hình, neo ở dưới cùng, màu Hồng/Đỏ san hô.
///
/// Responsibility:
///   - Cung cấp widget nút bấm tái sử dụng cho toàn bộ User App.
///   - Tuân thủ UI_Design_Rules: bo góc 12px, màu action (#E8687D),
///     chữ trắng SemiBold, padding ngang 16px.
///
/// Dependencies:
///   - app_user/lib/core/theme.dart (AppColors)
///
/// Todo:
///   - [ ] Thêm trạng thái loading (CircularProgressIndicator) khi isLoading = true
import 'package:flutter/material.dart';
import '../core/theme.dart';

// ==========================================
// PRIMARY BUTTON — WIDGET CHÍNH
// ==========================================

/// Nút Call-to-Action chính của User App.
///
/// Sử dụng màu [AppColors.action] (#E8687D), bo góc 12px,
/// trải dài toàn chiều rộng với margin ngang 16px theo UI_Design_Rules.
///
/// Ví dụ dùng ở cuối màn hình:
/// ```dart
/// PrimaryButton(
///   label: 'Đổi ngay',
///   onPressed: () => _handleRedeem(),
/// )
/// ```
class PrimaryButton extends StatelessWidget {
  /// Nhãn hiển thị trên nút (bắt buộc).
  final String label;

  /// Callback khi người dùng nhấn nút.
  /// Nếu null, nút ở trạng thái disabled (mờ đi).
  final VoidCallback? onPressed;

  /// Icon hiển thị bên trái nhãn (tuỳ chọn).
  final IconData? prefixIcon;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          // Màu nền lấy từ theme, không hardcode — UI_Design_Rules §Color Palette
          backgroundColor: AppColors.action,
          disabledBackgroundColor: AppColors.action.withOpacity(0.4),
          foregroundColor: Colors.white,
          // Bo góc 12px theo UI_Design_Rules §Shapes & Layout
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (prefixIcon != null) ...[
              Icon(prefixIcon, size: 20, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                // SemiBold (600) cho nút bấm theo UI_Design_Rules §Typography
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
