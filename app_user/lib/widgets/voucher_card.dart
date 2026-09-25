/// File: voucher_card.dart
/// Module: SharedWidgets
/// Description: Thẻ hiển thị thông tin một Voucher trong danh sách Rewards
///   của User App. Dạng Card trắng, bo góc 16px, đổ bóng nhạt.
///
/// Responsibility:
///   - Hiển thị ảnh, tên merchant, tiêu đề, và giá điểm của một voucher.
///   - Dùng CustomClipper tạo vết cắt ticket-notch nếu ở chế độ [isTicket].
///   - Tuân thủ UI_Design_Rules: bo góc 16px, shadow 0.05 opacity, màu từ theme.
///
/// Dependencies:
///   - app_user/lib/core/theme.dart (AppColors)
///
/// Todo:
///   - [ ] Thêm trạng thái [isExpired] để hiển thị overlay "Hết hạn"
///   - [ ] Kết nối [imageUrl] với network image khi có API thật
import 'package:flutter/material.dart';
import '../core/theme.dart';

// ==========================================
// DATA MODEL — DỮ LIỆU TRUYỀN VÀO CARD
// ==========================================

/// Data class chứa thông tin hiển thị của một Voucher trên Card.
/// Dùng để truyền từ màn hình danh sách xuống widget.
class VoucherCardData {
  final String title;
  final String merchantName;
  final int pointsCost;

  /// URL ảnh thumbnail của voucher (null = dùng placeholder).
  final String? imageUrl;

  const VoucherCardData({
    required this.title,
    required this.merchantName,
    required this.pointsCost,
    this.imageUrl,
  });
}

// ==========================================
// VOUCHER CARD — WIDGET CHÍNH
// ==========================================

/// Card hiển thị một Voucher trong danh sách Rewards.
///
/// Theo UI_Design_Rules §Shapes: bo góc 16px, shadow cực nhạt.
/// Kích thước phù hợp để dùng trong danh sách nằm ngang (horizontal ListView).
///
/// Ví dụ sử dụng:
/// ```dart
/// VoucherCard(
///   data: VoucherCardData(
///     title: 'Giảm 100k cho đơn 500k',
///     merchantName: 'The Pizza Company',
///     pointsCost: 300,
///   ),
///   onTap: () => Navigator.pushNamed(context, '/voucher-detail', ...),
/// )
/// ```
class VoucherCard extends StatelessWidget {
  final VoucherCardData data;
  final VoidCallback? onTap;

  /// Chiều rộng cố định của card (mặc định 180px, phù hợp list ngang).
  final double width;

  const VoucherCard({
    super.key,
    required this.data,
    this.onTap,
    this.width = 180,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: AppColors.card,
          // Bo góc 16px theo UI_Design_Rules §Shapes — Cards
          borderRadius: BorderRadius.circular(16),
          // Đổ bóng cực nhạt theo UI_Design_Rules §UI Components — Shadows
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // PHẦN ẢNH THUMBNAIL
            // ==========================================
            _buildThumbnail(),

            // ==========================================
            // PHẦN THÔNG TIN VOUCHER
            // ==========================================
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên merchant
                  Text(
                    data.merchantName,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      // Màu phụ từ theme, không hardcode
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Tiêu đề voucher
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Giá điểm — icon đồng xu + số điểm
                  _buildPointsBadge(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // HELPER BUILDERS
  // ==========================================

  /// Thumbnail phía trên card. Dùng network image nếu có URL,
  /// ngược lại hiển thị placeholder màu gradient.
  Widget _buildThumbnail() {
    return ClipRRect(
      // Bo góc chỉ ở 2 góc trên để khớp với Container cha
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: SizedBox(
        height: 110,
        width: double.infinity,
        child: data.imageUrl != null
            ? Image.network(
                data.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  /// Placeholder gradient khi chưa có ảnh thật (dùng cho MVP/Demo).
  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, Color(0xFFFFE680)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.card_giftcard, color: Colors.white, size: 36),
      ),
    );
  }

  /// Badge hiển thị số điểm cần để đổi voucher.
  /// Theo thiết kế mẫu: icon đồng xu vàng + số điểm đậm.
  Widget _buildPointsBadge() {
    return Row(
      children: [
        // Icon đồng xu — màu Primary (Vàng) theo UI_Design_Rules
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              '✦',
              style: TextStyle(fontSize: 10, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          _formatPoints(data.pointsCost),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// Định dạng số điểm theo chuẩn hiển thị:
  /// >= 1000 dùng dấu chấm phân cách (vd: 1.000, 10.000).
  String _formatPoints(int points) {
    if (points >= 1000) {
      // Chèn dấu chấm mỗi 3 chữ số từ phải sang
      final str = points.toString();
      final buffer = StringBuffer();
      for (int i = 0; i < str.length; i++) {
        if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
        buffer.write(str[i]);
      }
      return buffer.toString();
    }
    return points.toString();
  }
}
