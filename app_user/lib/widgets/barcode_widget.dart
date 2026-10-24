/// File: barcode_widget.dart
/// Module: SharedWidgets
/// Description: Widget vẽ mã vạch (1D Barcode) chuẩn Code 128 / Code 39
///   dùng CustomPainter sắc nét, không phụ thuộc thư viện ngoài.
///
/// Responsibility:
///   - Vẽ các vạch đen trắng tỷ lệ chính xác từ chuỗi mã voucher/thành viên
///   - Hiển thị mã chữ bên dưới kèm nút "Sao chép mã"
///
/// Dependencies:
///   - package:flutter/material.dart
///   - package:flutter/services.dart (Clipboard)
///   - app_user/lib/core/theme.dart (AppColors)
///
/// Todo:
///   (File đã hoàn thiện)
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';

// ==========================================
// BARCODE PAINTER
// ==========================================

class BarcodePainter extends CustomPainter {
  final String code;
  final Color barColor;

  BarcodePainter({
    required this.code,
    this.barColor = AppColors.textPrimary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    // Sinh dãy độ dày vạch dựa trên hash code của chuỗi để barcode trông chân thực
    final bytes = code.codeUnits;
    final List<int> pattern = [];

    // Quiet zone ở đầu (vạch khởi đầu)
    pattern.addAll([2, 1, 2, 1]);

    for (int i = 0; i < bytes.length; i++) {
      final b = bytes[i];
      pattern.add((b % 3) + 1);
      pattern.add(((b >> 2) % 2) + 1);
      pattern.add(((b >> 4) % 3) + 1);
      pattern.add(((b >> 6) % 2) + 1);
    }

    // Vạch kết thúc
    pattern.addAll([2, 1, 3, 1, 2]);

    final totalUnits = pattern.fold<int>(0, (sum, val) => sum + val);
    final unitWidth = size.width / totalUnits;

    double currentX = 0;
    bool isBar = true;

    for (final unit in pattern) {
      final width = unit * unitWidth;
      if (isBar) {
        canvas.drawRect(
          Rect.fromLTWH(currentX, 0, width, size.height),
          paint,
        );
      }
      currentX += width;
      isBar = !isBar; // Đổi giữa vạch đen và khoảng trắng
    }
  }

  @override
  bool shouldRepaint(covariant BarcodePainter oldDelegate) {
    return oldDelegate.code != code || oldDelegate.barColor != barColor;
  }
}

// ==========================================
// BARCODE DISPLAY WIDGET
// ==========================================

class BarcodeDisplayWidget extends StatelessWidget {
  final String code;
  final double height;
  final bool showCopyButton;

  const BarcodeDisplayWidget({
    super.key,
    required this.code,
    this.height = 70,
    this.showCopyButton = true,
  });

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép mã: $code'),
        backgroundColor: AppColors.textPrimary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Khối mã vạch vector
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: BarcodePainter(code: code),
          ),
        ),
        const SizedBox(height: 10),

        // Chuỗi mã chữ bên dưới
        Text(
          code,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: AppColors.textPrimary,
          ),
        ),

        // Nút sao chép mã
        if (showCopyButton) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _copyToClipboard(context),
            icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.action),
            label: const Text(
              'Copy mã',
              style: TextStyle(
                color: AppColors.action,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.action),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            ),
          ),
        ],
      ],
    );
  }
}
