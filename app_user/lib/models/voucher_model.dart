/// File: voucher_model.dart
/// Module: Models
/// Description: Data class đại diện cho Voucher và thông tin Merchant phát hành,
///   khớp với Voucher & Merchant entity của backend NestJS.
///
/// Responsibility:
///   - Chứa thông tin Voucher: tiêu đề, mô tả, giá điểm, tồn kho, hạn dùng
///   - Chứa thông tin Merchant: tên cửa hàng, ngành hàng (category)
///   - Parse JSON từ API (/vouchers, /vouchers/:id)
///
/// Dependencies:
///   - None
///
/// Todo:
///   (File đã hoàn thiện)
library;

class MerchantModel {
  final String id;
  final String name;
  final String? email;
  final String? category;
  final String? qrStaticCode;

  const MerchantModel({
    required this.id,
    required this.name,
    this.email,
    this.category,
    this.qrStaticCode,
  });

  factory MerchantModel.fromJson(Map<String, dynamic> json) {
    return MerchantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      category: json['category'] as String?,
      qrStaticCode: json['qr_static_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'category': category,
      'qr_static_code': qrStaticCode,
    };
  }
}

class VoucherModel {
  final String id;
  final String merchantId;
  final String? targetMerchantId;
  final String title;
  final String? description;
  final int pointsCost;
  final int totalQuantity;
  final int remainingQuantity;
  final DateTime expiredAt;
  final DateTime? createdAt;
  final MerchantModel? merchant;
  final MerchantModel? targetMerchant;

  const VoucherModel({
    required this.id,
    required this.merchantId,
    this.targetMerchantId,
    required this.title,
    this.description,
    required this.pointsCost,
    required this.totalQuantity,
    required this.remainingQuantity,
    required this.expiredAt,
    this.createdAt,
    this.merchant,
    this.targetMerchant,
  });

  /// Kiểm tra xem voucher đã hết hạn chưa
  bool get isExpired => DateTime.now().isAfter(expiredAt);

  /// Tên merchant an toàn
  String get merchantName => merchant?.name ?? 'TingTing Partner';

  /// Kiểm tra có phải voucher liên kết kích cầu đối tác không
  bool get isCrossMerchant => targetMerchant != null || (targetMerchantId != null && targetMerchantId!.isNotEmpty);

  /// Tên đối tác áp dụng voucher
  String get targetMerchantName => targetMerchant?.name ?? merchantName;

  /// Lấy ảnh chất lượng cao thực tế tương ứng với từng thương hiệu / voucher
  String get realImageUrl {
    final lowerTitle = title.toLowerCase();
    final lowerMerchant = merchantName.toLowerCase();
    final lowerTarget = targetMerchantName.toLowerCase();

    // 1. Nếu là deal liên kết, ưu tiên ảnh theo đối tác áp dụng
    final searchScope = '$lowerMerchant $lowerTarget $lowerTitle';

    // CGV Cinemas (Rạp chiếu phim, vé xem phim, bắp rang bơ)
    if (searchScope.contains('cgv') || searchScope.contains('phim') || searchScope.contains('cinema')) {
      return 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800&auto=format&fit=crop&q=80';
    }

    // Uniqlo (Thời trang cao cấp, LifeWear)
    if (searchScope.contains('uniqlo') || searchScope.contains('thời trang') || searchScope.contains('lifewear')) {
      return 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&auto=format&fit=crop&q=80';
    }

    // Highlands Coffee (Cà phê phin, phin sữa đá)
    if (searchScope.contains('highlands')) {
      if (lowerTitle.contains('phin') || lowerTitle.contains('cà phê') || lowerTitle.contains('coffee')) {
        return 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=800&auto=format&fit=crop&q=80';
      }
      return 'https://images.unsplash.com/photo-1541167760496-1628856ab772?w=800&auto=format&fit=crop&q=80';
    }

    // Phúc Long (Trà sữa, trà đào cam sả)
    if (searchScope.contains('phúc long') || searchScope.contains('phuclong')) {
      return 'https://images.unsplash.com/photo-1558857563-b37cfb8cb837?w=800&auto=format&fit=crop&q=80';
    }

    // The Coffee House (Cà phê bọt sữa, bánh ngọt)
    if (searchScope.contains('the coffee house') || searchScope.contains('coffee house')) {
      if (lowerTitle.contains('bánh')) {
        return 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800&auto=format&fit=crop&q=80';
      }
      return 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800&auto=format&fit=crop&q=80';
    }

    // Gong Cha (Trà sữa trân châu đen)
    if (searchScope.contains('gong cha')) {
      return 'https://images.unsplash.com/photo-1556881286-fc6915169721?w=800&auto=format&fit=crop&q=80';
    }

    // Pizza 4P's (Pizza lò củi, phô mai thơm lừng)
    if (searchScope.contains('4p') || searchScope.contains('pizza')) {
      return 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800&auto=format&fit=crop&q=80';
    }

    // Haidilao Hotpot (Nồi lẩu nóng hổi, bò Wagyu)
    if (searchScope.contains('haidilao') || searchScope.contains('lẩu')) {
      return 'https://images.unsplash.com/photo-1547928576-a4a33237cbc3?w=800&auto=format&fit=crop&q=80';
    }

    // Circle K (Đồ ăn nhanh, mì trộn xúc xích, snack tiện lợi)
    if (searchScope.contains('circle k')) {
      return 'https://images.unsplash.com/photo-1578916171728-46686eac8d58?w=800&auto=format&fit=crop&q=80';
    }

    // Guardian (Mỹ phẩm dưỡng da, kem chống nắng)
    if (searchScope.contains('guardian') || searchScope.contains('mỹ phẩm')) {
      return 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=800&auto=format&fit=crop&q=80';
    }

    // Ảnh mặc định ẩm thực cao cấp
    return 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&auto=format&fit=crop&q=80';
  }

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['id'] as String,
      merchantId: json['merchant_id'] as String,
      targetMerchantId: json['target_merchant_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      pointsCost: (json['points_cost'] as num).toInt(),
      totalQuantity: (json['total_quantity'] as num).toInt(),
      remainingQuantity: (json['remaining_quantity'] as num).toInt(),
      expiredAt: DateTime.parse(json['expired_at'] as String),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      merchant: json['merchant'] != null
          ? MerchantModel.fromJson(json['merchant'] as Map<String, dynamic>)
          : null,
      targetMerchant: json['target_merchant'] != null
          ? MerchantModel.fromJson(json['target_merchant'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchant_id': merchantId,
      'target_merchant_id': targetMerchantId,
      'title': title,
      'description': description,
      'points_cost': pointsCost,
      'total_quantity': totalQuantity,
      'remaining_quantity': remainingQuantity,
      'expired_at': expiredAt.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'merchant': merchant?.toJson(),
      'target_merchant': targetMerchant?.toJson(),
    };
  }
}
