/// File: merchant_voucher_model.dart
/// Module: Models
/// Description: Data class biểu diễn Voucher do Merchant phát hành.
///
/// Responsibility:
///   - Ánh xạ JSON từ GET /merchants/vouchers và POST /merchants/vouchers
///   - Cung cấp getter kiểm tra trạng thái (isActive, isExpired, isOutOfStock)
///
/// Dependencies:
///   - Không có
///
/// Todo:
///   - [ ] Bổ sung trường banner_image khi backend hỗ trợ upload ảnh
library;

class MerchantVoucher {
  final String id;
  final String merchantId;
  final String? targetMerchantId;
  final String? targetMerchantName;
  final String? issuerMerchantName;
  final String title;
  final String? description;
  final int pointsCost;
  final int totalQuantity;
  final int remainingQuantity;
  final DateTime expiredAt;
  final DateTime? createdAt;

  const MerchantVoucher({
    required this.id,
    required this.merchantId,
    this.targetMerchantId,
    this.targetMerchantName,
    this.issuerMerchantName,
    required this.title,
    this.description,
    required this.pointsCost,
    required this.totalQuantity,
    required this.remainingQuantity,
    required this.expiredAt,
    this.createdAt,
  });

  bool get isExpired => expiredAt.isBefore(DateTime.now());
  bool get isOutOfStock => remainingQuantity <= 0;
  bool get isActive => !isExpired && !isOutOfStock;
  bool get isCrossMerchant => targetMerchantId != null && targetMerchantId!.isNotEmpty;

  factory MerchantVoucher.fromJson(Map<String, dynamic> json) {
    final targetMerchant = json['target_merchant'] as Map<String, dynamic>?;
    final merchant = json['merchant'] as Map<String, dynamic>?;

    return MerchantVoucher(
      id: json['id'] as String? ?? '',
      merchantId: json['merchant_id'] as String? ?? '',
      targetMerchantId: json['target_merchant_id'] as String?,
      targetMerchantName: targetMerchant?['name'] as String?,
      issuerMerchantName: merchant?['name'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      pointsCost: json['points_cost'] as int? ?? 0,
      totalQuantity: json['total_quantity'] as int? ?? 0,
      remainingQuantity: json['remaining_quantity'] as int? ?? 0,
      expiredAt: json['expired_at'] != null
          ? DateTime.tryParse(json['expired_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
