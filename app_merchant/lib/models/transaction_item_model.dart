/// File: transaction_item_model.dart
/// Module: Models
/// Description: Data class biểu diễn giao dịch của cửa hàng.
///
/// Responsibility:
///   - Ánh xạ JSON từ API GET /merchants/me/transactions
///
/// Dependencies:
///   - Không có
///
/// Todo:
///   - [ ] Bổ sung trường chi tiết hóa đơn khi có POS integration
library;

class TransactionItem {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String type; // 'EARN' | 'REDEEM'
  final int pointsDelta;
  final double billAmount;
  final DateTime createdAt;

  const TransactionItem({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.type,
    required this.pointsDelta,
    required this.billAmount,
    required this.createdAt,
  });

  bool get isEarn => type == 'EARN';

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      userName: json['user_name'] as String? ?? 'Khách hàng',
      userPhone: json['user_phone'] as String? ?? '',
      type: json['type'] as String? ?? 'EARN',
      pointsDelta: json['points_delta'] as int? ?? 0,
      billAmount: (json['bill_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
