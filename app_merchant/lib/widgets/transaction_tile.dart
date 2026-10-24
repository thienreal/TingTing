/// File: transaction_tile.dart
/// Module: SharedWidgets
/// Description: Tile hiển thị một dòng lịch sử giao dịch trong Merchant App.
///   Dùng trong danh sách Report/History của cửa hàng.
///
/// Responsibility:
///   - Hiển thị thông tin giao dịch: loại (cộng/trừ điểm, đổi voucher),
///     tên user/voucher, số điểm delta, thời gian.
///   - Phân biệt màu delta: xanh lá khi cộng điểm (+), đỏ khi trừ (-).
///   - Tuân thủ UI_Design_Rules: nền trắng, shadow nhạt, padding 16px.
///
/// Dependencies:
///   - app_merchant/lib/core/theme.dart (AppColors)
///
/// Todo:
///   - [ ] Hỗ trợ swipe-to-delete để huỷ giao dịch nhầm (cần API support)
library;

import 'package:flutter/material.dart';
import '../core/theme.dart';

// ==========================================
// ENUM — LOẠI GIAO DỊCH
// ==========================================

/// Phân loại giao dịch để hiển thị icon và màu delta phù hợp.
enum TransactionType {
  /// Merchant cộng điểm cho User sau khi thanh toán.
  earnPoints,

  /// User dùng điểm để đổi Voucher.
  redeemVoucher,

  /// User sử dụng Voucher tại cửa hàng.
  useVoucher,
}

// ==========================================
// DATA MODEL
// ==========================================

/// Data class chứa thông tin một giao dịch cần hiển thị trên Tile.
class TransactionTileData {
  final TransactionType type;

  /// Tên người dùng (masked, ví dụ: "Nguyen V. A.") hoặc tên voucher.
  final String subject;

  /// Delta điểm (dương = cộng, âm = trừ). Ví dụ: +300, -500.
  final int pointsDelta;

  /// Số tiền hóa đơn (chỉ có khi type = earnPoints).
  final double? billAmount;

  /// Thời điểm giao dịch.
  final DateTime createdAt;

  const TransactionTileData({
    required this.type,
    required this.subject,
    required this.pointsDelta,
    required this.createdAt,
    this.billAmount,
  });
}

// ==========================================
// TRANSACTION TILE — WIDGET CHÍNH
// ==========================================

/// Tile hiển thị một dòng giao dịch trong danh sách lịch sử của Merchant App.
///
/// Theo thiết kế: card trắng bo góc 12px, đổ bóng nhạt.
/// Delta điểm hiển thị màu xanh lá (+) hoặc đỏ san hô (-).
class TransactionTile extends StatelessWidget {
  final TransactionTileData data;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          // Shadow nhạt giống UI_Design_Rules §UI Components — Shadows
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ==========================================
            // ICON PHÂN LOẠI GIAO DỊCH
            // ==========================================
            _buildTypeIcon(),
            const SizedBox(width: 12),

            // ==========================================
            // THÔNG TIN GIAO DỊCH (GIỮA)
            // ==========================================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _typeLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.subject,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (data.billAmount != null && data.billAmount! > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Hóa đơn: ${_formatCurrency(data.billAmount!)}đ',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ==========================================
            // DELTA ĐIỂM + THỜI GIAN (PHẢI)
            // ==========================================
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formattedDelta,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _deltaColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formattedTime,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // HELPER GETTERS & METHODS
  // ==========================================

  Widget _buildTypeIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _iconBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(_typeIcon, color: _iconColor, size: 20),
    );
  }

  IconData get _typeIcon {
    switch (data.type) {
      case TransactionType.earnPoints:
        return Icons.add_circle_outline_rounded;
      case TransactionType.redeemVoucher:
        return Icons.card_giftcard_outlined;
      case TransactionType.useVoucher:
        return Icons.check_circle_outline_rounded;
    }
  }

  Color get _iconColor {
    switch (data.type) {
      case TransactionType.earnPoints:
        return const Color(0xFF2ECC71); // Xanh lá
      case TransactionType.redeemVoucher:
      case TransactionType.useVoucher:
        return AppColors.action; // Hồng
    }
  }

  Color get _iconBackgroundColor {
    switch (data.type) {
      case TransactionType.earnPoints:
        return const Color(0xFF2ECC71).withValues(alpha: 0.1);
      case TransactionType.redeemVoucher:
      case TransactionType.useVoucher:
        return AppColors.action.withValues(alpha: 0.1);
    }
  }

  String get _typeLabel {
    switch (data.type) {
      case TransactionType.earnPoints:
        return 'Cộng điểm';
      case TransactionType.redeemVoucher:
        return 'Đổi voucher';
      case TransactionType.useVoucher:
        return 'Sử dụng voucher';
    }
  }

  String get _formattedDelta {
    final sign = data.pointsDelta > 0 ? '+' : '';
    return '$sign${data.pointsDelta} điểm';
  }

  Color get _deltaColor {
    return data.pointsDelta > 0
        ? const Color(0xFF2ECC71)
        : AppColors.action;
  }

  String get _formattedTime {
    final dt = data.createdAt;
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    return '$h:$m • $d/$mo/${dt.year}';
  }

  String _formatCurrency(double amount) {
    final intAmount = amount.toInt();
    final str = intAmount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
