/// File: user_voucher_model.dart
/// Module: Models
/// Description: Data class đại diện cho Voucher mà người dùng đã đổi,
///   khớp với UserVoucher entity của backend NestJS.
///
/// Responsibility:
///   - Lưu trữ thông tin voucher cá nhân (mã vé, trạng thái, thời gian đổi)
///   - Chứa nested VoucherModel để hiển thị chi tiết tên, merchant, mô tả
///   - Phân loại trạng thái: ACTIVE (Đang có), USED (Đã dùng), EXPIRED (Hết hạn)
///
/// Dependencies:
///   - app_user/lib/models/voucher_model.dart
///
/// Todo:
///   (File đã hoàn thiện)
library;

import 'voucher_model.dart';

enum UserVoucherState {
  active,
  used,
  expired,
}

class UserVoucherModel {
  final String id;
  final String userId;
  final String voucherId;
  final String status; // 'ACTIVE' | 'USED' | 'EXPIRED'
  final DateTime? redeemedAt;
  final VoucherModel? voucher;

  const UserVoucherModel({
    required this.id,
    required this.userId,
    required this.voucherId,
    required this.status,
    this.redeemedAt,
    this.voucher,
  });

  /// Kiểm tra trạng thái thân thiện
  bool get isActive => status == 'ACTIVE';
  bool get isUsed => status == 'USED';
  bool get isExpired => status == 'EXPIRED' || (voucher?.isExpired ?? false);

  UserVoucherState get state {
    if (isUsed) return UserVoucherState.used;
    if (isExpired) return UserVoucherState.expired;
    return UserVoucherState.active;
  }

  factory UserVoucherModel.fromJson(Map<String, dynamic> json) {
    return UserVoucherModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      voucherId: json['voucher_id'] as String,
      status: (json['status'] as String?) ?? 'ACTIVE',
      redeemedAt: json['redeemed_at'] != null
          ? DateTime.tryParse(json['redeemed_at'] as String)
          : null,
      voucher: json['voucher'] != null
          ? VoucherModel.fromJson(json['voucher'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'voucher_id': voucherId,
      'status': status,
      'redeemed_at': redeemedAt?.toIso8601String(),
      'voucher': voucher?.toJson(),
    };
  }
}
