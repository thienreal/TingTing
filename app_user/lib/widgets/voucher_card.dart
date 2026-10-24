/// File: voucher_card.dart
/// Module: SharedWidgets
/// Description: Thẻ hiển thị thông tin một Voucher trong danh sách Rewards
///   của User App. Dạng Card trắng, bo góc 16px, đổ bóng nhạt theo UI_Design_Rules.
///
/// Responsibility:
///   - Hiển thị ảnh, tên merchant, tiêu đề, và giá điểm của một voucher.
///   - Hỗ trợ cả VoucherCardData hoặc trực tiếp từ VoucherModel.
///   - Tuân thủ UI_Design_Rules: bo góc 16px, shadow 0.05 opacity, màu từ theme.
///
/// Dependencies:
///   - app_user/lib/core/theme.dart (AppColors)
///   - app_user/lib/models/voucher_model.dart (VoucherModel)
///
/// Todo:
///   (File đã hoàn thiện)
library;

import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/voucher_model.dart';

// ==========================================
// DATA MODEL — DỮ LIỆU TRUYỀN VÀO CARD
// ==========================================

class VoucherCardData {
  final String? id;
  final String title;
  final String merchantName;
  final int pointsCost;
  final String? imageUrl;
  final String? tag; // vd: 'Tặng', 'Hot'
  final bool isCrossMerchant;
  final String? targetMerchantName;

  const VoucherCardData({
    this.id,
    required this.title,
    required this.merchantName,
    required this.pointsCost,
    this.imageUrl,
    this.tag,
    this.isCrossMerchant = false,
    this.targetMerchantName,
  });

  factory VoucherCardData.fromModel(VoucherModel model, {String? tag}) {
    final isCross = model.isCrossMerchant;
    return VoucherCardData(
      id: model.id,
      title: model.title,
      merchantName: model.merchantName,
      pointsCost: model.pointsCost,
      imageUrl: model.realImageUrl,
      tag: tag ?? (isCross ? '🤝 Liên minh' : (model.pointsCost <= 500 ? 'Tặng' : null)),
      isCrossMerchant: isCross,
      targetMerchantName: model.targetMerchantName,
    );
  }
}

// ==========================================
// VOUCHER CARD — WIDGET CHÍNH
// ==========================================

class VoucherCard extends StatelessWidget {
  final VoucherCardData data;
  final VoidCallback? onTap;
  final double width;

  const VoucherCard({
    super.key,
    required this.data,
    this.onTap,
    this.width = 170,
  });

  factory VoucherCard.fromModel(
    VoucherModel model, {
    Key? key,
    VoidCallback? onTap,
    double width = 170,
    String? tag,
  }) {
    return VoucherCard(
      key: key,
      data: VoucherCardData.fromModel(model, tag: tag),
      onTap: onTap,
      width: width,
    );
  }

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
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ==========================================
            // PHẦN ẢNH THUMBNAIL CÓ BADGE TAG
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
                    data.isCrossMerchant
                        ? '${data.merchantName} ➔ ${data.targetMerchantName}'
                        : data.merchantName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: data.isCrossMerchant ? FontWeight.w700 : FontWeight.w500,
                      color: data.isCrossMerchant ? AppColors.action : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Tiêu đề voucher
                  SizedBox(
                    height: 36,
                    child: Text(
                      data.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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

  Widget _buildThumbnail() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: SizedBox(
            height: 105,
            width: double.infinity,
            child: data.imageUrl != null
                ? Image.network(
                    data.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
          ),
        ),
        if (data.tag != null)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: data.isCrossMerchant
                    ? AppColors.action
                    : Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                data.tag!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.85),
            const Color(0xFFFFE680),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.card_giftcard_rounded,
          color: Colors.white.withOpacity(0.9),
          size: 40,
        ),
      ),
    );
  }

  Widget _buildPointsBadge() {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              '✦',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          _formatPoints(data.pointsCost),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  String _formatPoints(int points) {
    if (points >= 1000) {
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
