/// File: ticket_notch_clipper.dart
/// Module: SharedWidgets
/// Description: CustomClipper và Widget thẻ Voucher có vết cắt bán nguyệt (notch)
///   ở 2 cạnh bên và đường nét đứt phân cách, tuân thủ UI_Design_Rules §Shapes.
///
/// Responsibility:
///   - Cung cấp TicketNotchClipper cắt khoét 2 nửa hình tròn ở 2 cạnh
///   - Cung cấp DashedLinePainter vẽ đường nét đứt giữa 2 vết khoét
///   - Cung cấp TicketContainer bao bọc nội dung thẻ voucher chuyên nghiệp
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
// TICKET NOTCH CLIPPER
// ==========================================

/// Clipper tạo hình chữ nhật bo góc với 2 vết cắt bán nguyệt (notches) ở 2 bên.
class TicketNotchClipper extends CustomClipper<Path> {
  final double notchRadius;
  final double notchPosition; // Vị trí Y tính từ đỉnh hoặc tỷ lệ
  final double borderRadius;
  final bool isRatio;

  TicketNotchClipper({
    this.notchRadius = 10.0,
    this.notchPosition = 0.65,
    this.borderRadius = 16.0,
    this.isRatio = true,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final notchY = isRatio ? size.height * notchPosition : notchPosition;

    // Góc trên bên trái
    path.moveTo(0, borderRadius);
    path.quadraticBezierTo(0, 0, borderRadius, 0);

    // Cạnh trên
    path.lineTo(size.width - borderRadius, 0);
    // Góc trên bên phải
    path.quadraticBezierTo(size.width, 0, size.width, borderRadius);

    // Cạnh phải đến vết cắt
    path.lineTo(size.width, notchY - notchRadius);
    // Vết cắt bán nguyệt bên phải (lõm vào trong thẻ)
    path.arcToPoint(
      Offset(size.width, notchY + notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    // Cạnh phải đến góc dưới
    path.lineTo(size.width, size.height - borderRadius);
    // Góc dưới bên phải
    path.quadraticBezierTo(size.width, size.height, size.width - borderRadius, size.height);

    // Cạnh dưới
    path.lineTo(borderRadius, size.height);
    // Góc dưới bên trái
    path.quadraticBezierTo(0, size.height, 0, size.height - borderRadius);

    // Cạnh trái từ dưới lên vết cắt
    path.lineTo(0, notchY + notchRadius);
    // Vết cắt bán nguyệt bên trái (lõm vào trong thẻ)
    path.arcToPoint(
      Offset(0, notchY - notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    // Đóng lại về góc trên bên trái
    path.lineTo(0, borderRadius);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant TicketNotchClipper oldClipper) {
    return oldClipper.notchRadius != notchRadius ||
        oldClipper.notchPosition != notchPosition ||
        oldClipper.borderRadius != borderRadius ||
        oldClipper.isRatio != isRatio;
  }
}

// ==========================================
// VẼ ĐƯỜNG NÉT ĐỨT PHÂN CÁCH (DASHED LINE)
// ==========================================

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;

  DashedLinePainter({
    this.color = AppColors.border,
    this.dashWidth = 6.0,
    this.dashSpace = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    double startX = 0;
    final y = size.height / 2;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + dashWidth, y),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant DashedLinePainter oldDelegate) => false;
}

// ==========================================
// TICKET CONTAINER WIDGET
// ==========================================

/// Container hình chiếc vé với 2 vết cắt bán nguyệt và viền đỏ/hồng nhạt hoặc trắng
class TicketContainer extends StatelessWidget {
  final Widget child;
  final double notchRadius;
  final double notchPosition;
  final Color backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final bool isRatio;

  const TicketContainer({
    super.key,
    required this.child,
    this.notchRadius = 10.0,
    this.notchPosition = 0.65,
    this.backgroundColor = AppColors.card,
    this.borderColor,
    this.borderRadius = 16.0,
    this.isRatio = true,
  });

  @override
  Widget build(BuildContext context) {
    return PhysicalShape(
      clipper: TicketNotchClipper(
        notchRadius: notchRadius,
        notchPosition: notchPosition,
        borderRadius: borderRadius,
        isRatio: isRatio,
      ),
      color: backgroundColor,
      shadowColor: Colors.black.withOpacity(0.08),
      elevation: 4,
      child: child,
    );
  }
}
