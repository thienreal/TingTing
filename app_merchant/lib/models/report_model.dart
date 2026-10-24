/// File: report_model.dart
/// Module: Models
/// Description: Data class biểu diễn các chỉ số báo cáo kinh doanh của Merchant.
///
/// Responsibility:
///   - Ánh xạ JSON từ API GET /merchants/me/report
///
/// Dependencies:
///   - Không có
///
/// Todo:
///   - [ ] Thêm chỉ số doanh thu theo khoảng thời gian (ngày/tuần/tháng)
library;

class MerchantReport {
  final int activeVouchersCount;
  final int totalPointsIssued;
  final int totalTransactions;
  final int usedVouchersCount;

  const MerchantReport({
    required this.activeVouchersCount,
    required this.totalPointsIssued,
    required this.totalTransactions,
    required this.usedVouchersCount,
  });

  factory MerchantReport.fromJson(Map<String, dynamic> json) {
    return MerchantReport(
      activeVouchersCount: json['active_vouchers_count'] as int? ?? 0,
      totalPointsIssued: json['total_points_issued'] as int? ?? 0,
      totalTransactions: json['total_transactions'] as int? ?? 0,
      usedVouchersCount: json['used_vouchers_count'] as int? ?? 0,
    );
  }

  factory MerchantReport.empty() {
    return const MerchantReport(
      activeVouchersCount: 0,
      totalPointsIssued: 0,
      totalTransactions: 0,
      usedVouchersCount: 0,
    );
  }
}
