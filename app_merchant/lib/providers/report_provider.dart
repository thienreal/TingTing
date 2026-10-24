/// File: report_provider.dart
/// Module: Providers
/// Description: Quản lý dữ liệu báo cáo kinh doanh và lịch sử giao dịch của cửa hàng theo Riverpod 3.0.
///
/// Responsibility:
///   - Gọi GET /merchants/me/report để cập nhật 4 thẻ KPI
///   - Gọi GET /merchants/me/transactions để cập nhật danh sách giao dịch gần nhất
///   - Hỗ trợ refresh real-time sau khi tích điểm hoặc áp dụng voucher
///
/// Dependencies:
///   - package:flutter_riverpod/flutter_riverpod.dart
///   - app_merchant/lib/core/api_client.dart
///   - app_merchant/lib/models/report_model.dart
///   - app_merchant/lib/models/transaction_item_model.dart
///
/// Todo:
///   - [ ] Bổ sung biểu đồ doanh thu theo biểu đồ cột/đường
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/report_model.dart';
import '../models/transaction_item_model.dart';

// ==========================================
// REPORT STATE
// ==========================================

class ReportState {
  final bool isLoading;
  final MerchantReport report;
  final List<TransactionItem> recentTransactions;
  final String? errorMessage;

  const ReportState({
    this.isLoading = false,
    required this.report,
    this.recentTransactions = const [],
    this.errorMessage,
  });

  ReportState copyWith({
    bool? isLoading,
    MerchantReport? report,
    List<TransactionItem>? recentTransactions,
    String? errorMessage,
  }) {
    return ReportState(
      isLoading: isLoading ?? this.isLoading,
      report: report ?? this.report,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      errorMessage: errorMessage,
    );
  }
}

// ==========================================
// NOTIFIER
// ==========================================

class ReportNotifier extends Notifier<ReportState> {
  @override
  ReportState build() {
    return ReportState(report: MerchantReport.empty());
  }

  /// Tải dữ liệu báo cáo và danh sách giao dịch từ API
  Future<void> fetchDashboardData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Gọi song song cả report và recent transactions để tối ưu tốc độ
      final responses = await Future.wait([
        ApiClient.dio.get('/merchants/me/report'),
        ApiClient.dio.get('/merchants/me/transactions'),
      ]);

      final reportJson = responses[0].data as Map<String, dynamic>;
      final report = MerchantReport.fromJson(reportJson);

      final txListJson = responses[1].data as List<dynamic>;
      final recentTransactions = txListJson
          .map((item) => TransactionItem.fromJson(item as Map<String, dynamic>))
          .toList();

      state = ReportState(
        isLoading: false,
        report: report,
        recentTransactions: recentTransactions,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.response?.data?['message']?.toString() ?? 'Lỗi tải dữ liệu báo cáo',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Lỗi không xác định: $e',
      );
    }
  }
}

// ==========================================
// PROVIDER
// ==========================================

final reportProvider = NotifierProvider<ReportNotifier, ReportState>(
  ReportNotifier.new,
);
