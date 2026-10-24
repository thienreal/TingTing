/// File: merchant_model.dart
/// Module: Models
/// Description: Data class biểu diễn thông tin Cửa hàng đối tác (Merchant).
///
/// Responsibility:
///   - Ánh xạ dữ liệu JSON từ API đăng nhập hoặc profile Merchant
///   - Cung cấp serialization toJson và deserialization fromJson
///
/// Dependencies:
///   - Không có
///
/// Todo:
///   - [ ] Bổ sung thông tin địa chỉ chi nhánh (branches) khi mở rộng
library;

class Merchant {
  final String id;
  final String name;
  final String email;
  final String category;
  final String qrStaticCode;

  const Merchant({
    required this.id,
    required this.name,
    required this.email,
    required this.category,
    required this.qrStaticCode,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      category: json['category'] as String? ?? '',
      qrStaticCode: json['qr_static_code'] as String? ?? '',
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
