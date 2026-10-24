/// File: transaction_model.dart
/// Module: Models
/// Description: Data class đại diện cho Lịch sử Giao dịch (Tích điểm / Đổi quà),
///   khớp với Transaction entity của backend NestJS.
///
/// Responsibility:
///   - Lưu trữ biến động điểm (+/- points_delta), số tiền hóa đơn, thời gian
///   - Chứa thông tin Merchant đối tác phát sinh giao dịch
///   - Parse JSON từ API /users/me/transactions
///
/// Dependencies:
///   - app_user/lib/models/voucher_model.dart (MerchantModel)
///
/// Todo:
///   (File đã hoàn thiện)
library;

import 'voucher_model.dart';

class TransactionModel {
  final String id;
  final String userId;
  final String merchantId;
  final String type; // 'EARN' | 'REDEEM'
  final int pointsDelta;
  final double? billAmount;
  final DateTime createdAt;
  final MerchantModel? merchant;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.merchantId,
    required this.type,
    required this.pointsDelta,
    this.billAmount,
    required this.createdAt,
    this.merchant,
  });

  /// Giao dịch cộng điểm tích lũy tại quầy
  bool get isEarn => type == 'EARN';

  /// Giao dịch trừ điểm khi đổi voucher
  bool get isRedeem => type == 'REDEEM';

  String get merchantName => merchant?.name ?? 'TingTing Partner';

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      merchantId: json['merchant_id'] as String,
      type: json['type'] as String,
      pointsDelta: (json['points_delta'] as num).toInt(),
      billAmount: json['bill_amount'] != null
          ? double.tryParse(json['bill_amount'].toString())
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      merchant: json['merchant'] != null
          ? MerchantModel.fromJson(json['merchant'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'merchant_id': merchantId,
      'type': type,
      'points_delta': pointsDelta,
      'bill_amount': billAmount,
      'created_at': createdAt.toIso8601String(),
      'merchant': merchant?.toJson(),
    };
  }
}
