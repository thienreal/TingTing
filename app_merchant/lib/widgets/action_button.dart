/// File: action_button.dart
/// Module: SharedWidgets
/// Description: Nút hành động chính của Merchant App (Quét QR, Xác nhận...).
///   Thiết kế tương tự PrimaryButton của User App nhưng
///   màu Primary (Vàng #FAD240) để phân biệt ngữ cảnh B2B.
///
/// Responsibility:
///   - Cung cấp widget nút bấm tái sử dụng cho toàn bộ Merchant App.
///   - Hỗ trợ variant: filled (mặc định) và outlined (thứ cấp).
///   - Tuân thủ UI_Design_Rules: bo góc 12px, full width, màu từ theme.
///
/// Dependencies:
///   - app_merchant/lib/core/theme.dart (AppColors)
///
/// Todo:
///   - [ ] Thêm trạng thái loading (CircularProgressIndicator)
import 'package:flutter/material.dart';
import '../core/theme.dart';

// ==========================================
// ENUM — KIỂU HIỂN THỊ NÚT
// ==========================================

/// Kiểu hiển thị của [ActionButton].
/// - [filled]: Nền màu Primary (Vàng), chữ đen — dùng cho CTA chính.
/// - [outlined]: Viền màu action (Hồng), nền trong suốt — dùng cho hành động phụ.
enum ActionButtonVariant { filled, outlined }

// ==========================================
// ACTION BUTTON — WIDGET CHÍNH
// ==========================================

/// Nút hành động của Merchant App.
///
/// Dùng màu [AppColors.primary] (#FAD240) cho variant filled,
/// [AppColors.action] (#E8687D) cho variant outlined.
/// Bo góc 12px, trải dài full-width theo UI_Design_Rules.
///
/// Ví dụ sử dụng:
/// ```dart
/// // Nút chính: Quét QR
/// ActionButton(
///   label: 'Quét mã QR',
///   icon: Icons.qr_code_scanner,
///   onPressed: () => _openScanner(),
/// )
///
/// // Nút phụ: Huỷ
/// ActionButton(
///   label: 'Huỷ',
///   variant: ActionButtonVariant.outlined,
///   onPressed: () => Navigator.pop(context),
/// )
/// ```
class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ActionButtonVariant variant;

  const ActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = ActionButtonVariant.filled,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: variant == ActionButtonVariant.filled
          ? _buildFilledButton()
          : _buildOutlinedButton(),
    );
  }

  // ==========================================
  // VARIANT BUILDERS
  // ==========================================

  /// Nút nền vàng — dùng cho hành động chính trong Merchant App.
  Widget _buildFilledButton() {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        // Màu Primary (Vàng) cho Merchant App — phân biệt với User App màu Hồng
        backgroundColor: AppColors.primary,
        disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
        // Chữ đen trên nền vàng để đảm bảo contrast
        foregroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24),
      ),
      child: _buildButtonContent(labelColor: AppColors.textPrimary),
    );
  }

  /// Nút viền hồng — dùng cho hành động thứ cấp (huỷ, quay lại...).
  Widget _buildOutlinedButton() {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.action,
        side: BorderSide(
          color: onPressed != null
              ? AppColors.action
              : AppColors.action.withOpacity(0.3),
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
      ),
      child: _buildButtonContent(labelColor: AppColors.action),
    );
  }

  /// Nội dung bên trong nút: icon (tuỳ chọn) + nhãn chữ.
  Widget _buildButtonContent({required Color labelColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: labelColor),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: labelColor,
          ),
        ),
      ],
    );
  }
}
