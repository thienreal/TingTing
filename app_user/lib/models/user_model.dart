/// File: user_model.dart
/// Module: Models
/// Description: Data class đại diện cho User trong hệ thống TingTing,
///   khớp với User entity của backend NestJS.
///
/// Responsibility:
///   - Chứa thông tin người dùng: ID, SĐT, họ tên, tổng điểm, hạng thành viên
///   - Parse JSON từ API (/auth/verify-otp, /users/me)
///   - Serialize sang Map để lưu cache SharedPreferences
///
/// Dependencies:
///   - None
///
/// Todo:
///   (File đã hoàn thiện)
library;

class UserModel {
  final String id;
  final String phoneNumber;
  final String? fullName;
  final int totalPoints;
  final String membershipTier;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.phoneNumber,
    this.fullName,
    required this.totalPoints,
    required this.membershipTier,
    this.createdAt,
  });

  /// Tên hiển thị thân thiện (nếu chưa có họ tên thì dùng số điện thoại)
  String get displayName {
    if (fullName != null && fullName!.trim().isNotEmpty) {
      return fullName!;
    }
    return phoneNumber;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      phoneNumber: json['phone_number'] as String,
      fullName: json['full_name'] as String?,
      totalPoints: (json['total_points'] as num?)?.toInt() ?? 0,
      membershipTier: (json['membership_tier'] as String?) ?? 'STANDARD',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'full_name': fullName,
      'total_points': totalPoints,
      'membership_tier': membershipTier,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? fullName,
    int? totalPoints,
    String? membershipTier,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      totalPoints: totalPoints ?? this.totalPoints,
      membershipTier: membershipTier ?? this.membershipTier,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
