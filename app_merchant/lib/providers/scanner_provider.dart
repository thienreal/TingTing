/// File: scanner_provider.dart
/// Module: Providers
/// Description: Xử lý nghiệp vụ quét mã: Tích điểm (Earn Points) và Trừ Voucher (Use Voucher).
///
/// Responsibility:
///   - Gọi POST /points/earn với user_id và bill_amount
///   - Gọi POST /points/use-voucher với user_voucher_id
///   - Tự động làm mới Dashboard Report sau khi giao dịch thành công
///
/// Dependencies:
///   - package:flutter_riverpod/flutter_riverpod.dart
///   - app_merchant/lib/core/api_client.dart
///   - app_merchant/lib/providers/report_provider.dart
///
/// Todo:
///   - [ ] Bổ sung in hóa đơn nhiệt qua Bluetooth POS
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import 'report_provider.dart';

// ==========================================
// RESULT MODELS
// ==========================================

class EarnPointsResult {
  final int pointsEarned;
  final int newTotalPoints;
  final String newMembershipTier;
  final bool tierUpgraded;
  final double billAmount;

  const EarnPointsResult({
    required this.pointsEarned,
    required this.newTotalPoints,
    required this.newMembershipTier,
    required this.tierUpgraded,
    required this.billAmount,
  });
}

class UseVoucherResult {
  final String userVoucherId;
  final String voucherTitle;
  final String status;
  final DateTime usedAt;
  final bool isCrossMerchant;
  final String? issuerMerchantName;
  final String? targetMerchantName;

  const UseVoucherResult({
    required this.userVoucherId,
    required this.voucherTitle,
    required this.status,
    required this.usedAt,
    this.isCrossMerchant = false,
    this.issuerMerchantName,
    this.targetMerchantName,
  });
}

// ==========================================
// SCANNER STATE
// ==========================================

class ScannerState {
  final bool isProcessing;
  final EarnPointsResult? earnResult;
  final UseVoucherResult? voucherResult;
  final String? errorMessage;

  const ScannerState({
    this.isProcessing = false,
    this.earnResult,
    this.voucherResult,
    this.errorMessage,
  });

  ScannerState copyWith({
    bool? isProcessing,
    EarnPointsResult? earnResult,
    UseVoucherResult? voucherResult,
    String? errorMessage,
  }) {
    return ScannerState(
      isProcessing: isProcessing ?? this.isProcessing,
      earnResult: earnResult ?? this.earnResult,
      voucherResult: voucherResult ?? this.voucherResult,
      errorMessage: errorMessage,
    );
  }
}

// ==========================================
// NOTIFIER
// ==========================================

class ScannerNotifier extends Notifier<ScannerState> {
  @override
  ScannerState build() {
    return const ScannerState();
  }

  void reset() {
    state = const ScannerState();
  }

  /// Tích điểm cho khách hàng theo số tiền hóa đơn
  Future<bool> earnPoints({
    required String userId,
    required double billAmount,
  }) async {
    state = state.copyWith(isProcessing: true, errorMessage: null);

    try {
      final response = await ApiClient.dio.post(
        '/points/earn',
        data: {
          'user_id': userId.trim(),
          'bill_amount': billAmount,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final result = EarnPointsResult(
        pointsEarned: data['points_earned'] as int? ?? 0,
        newTotalPoints: data['new_total_points'] as int? ?? 0,
        newMembershipTier: data['new_membership_tier'] as String? ?? 'STANDARD',
        tierUpgraded: data['tier_upgraded'] as bool? ?? false,
        billAmount: billAmount,
      );

      state = ScannerState(
        isProcessing: false,
        earnResult: result,
      );

      // Cập nhật lại chỉ số báo cáo của cửa hàng
      ref.read(reportProvider.notifier).fetchDashboardData();

      return true;
    } on DioException catch (e) {
      String msg = 'Tích điểm thất bại';
      if (e.response?.data is Map && e.response?.data['message'] != null) {
        final err = e.response!.data['message'];
        msg = err is List ? err.join(', ') : err.toString();
      }
      state = state.copyWith(isProcessing: false, errorMessage: msg);
      return false;
    } catch (e) {
      state = state.copyWith(isProcessing: false, errorMessage: 'Lỗi: $e');
      return false;
    }
  }

  /// Xác nhận sử dụng voucher của khách
  Future<bool> useVoucher({
    required String userVoucherId,
  }) async {
    state = state.copyWith(isProcessing: true, errorMessage: null);

    try {
      final response = await ApiClient.dio.post(
        '/points/use-voucher',
        data: {
          'user_voucher_id': userVoucherId.trim(),
        },
      );

      final data = response.data as Map<String, dynamic>;
      final voucherObj = data['voucher'] as Map<String, dynamic>?;
      final voucherTitle = voucherObj?['title'] as String? ?? 'Voucher Ưu Đãi';
      final targetObj = voucherObj?['target_merchant'] as Map<String, dynamic>?;
      final issuerObj = voucherObj?['merchant'] as Map<String, dynamic>?;

      final result = UseVoucherResult(
        userVoucherId: userVoucherId,
        voucherTitle: voucherTitle,
        status: data['status'] as String? ?? 'USED',
        usedAt: DateTime.now(),
        isCrossMerchant: targetObj != null,
        issuerMerchantName: issuerObj?['name'] as String?,
        targetMerchantName: targetObj?['name'] as String?,
      );

      state = ScannerState(
        isProcessing: false,
        voucherResult: result,
      );

      // Cập nhật lại chỉ số báo cáo của cửa hàng
      ref.read(reportProvider.notifier).fetchDashboardData();

      return true;
    } on DioException catch (e) {
      String msg = 'Áp dụng voucher thất bại';
      if (e.response?.data is Map && e.response?.data['message'] != null) {
        final err = e.response!.data['message'];
        msg = err is List ? err.join(', ') : err.toString();
      }
      state = state.copyWith(isProcessing: false, errorMessage: msg);
      return false;
    } catch (e) {
      state = state.copyWith(isProcessing: false, errorMessage: 'Lỗi: $e');
      return false;
    }
  }
}

// ==========================================
// PROVIDER
// ==========================================

final scannerProvider = NotifierProvider<ScannerNotifier, ScannerState>(
  ScannerNotifier.new,
);
