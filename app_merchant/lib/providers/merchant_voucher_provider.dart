/// File: merchant_voucher_provider.dart
/// Module: Providers
/// Description: Quản lý danh sách voucher và tạo deal ưu đãi mới của Merchant theo Riverpod 3.0.
///
/// Responsibility:
///   - Gọi GET /merchants/vouchers để tải danh sách ưu đãi của quán
///   - Gọi POST /merchants/vouchers để phát hành ưu đãi mới
///   - Tự động cập nhật danh sách và làm mới Dashboard report
///
/// Dependencies:
///   - package:flutter_riverpod/flutter_riverpod.dart
///   - app_merchant/lib/core/api_client.dart
///   - app_merchant/lib/models/merchant_voucher_model.dart
///   - app_merchant/lib/providers/report_provider.dart
///
/// Todo:
///   - [ ] Bổ sung tính năng tạm dừng/kích hoạt lại voucher
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/merchant_model.dart';
import '../models/merchant_voucher_model.dart';
import 'report_provider.dart';

// ==========================================
// VOUCHER STATE
// ==========================================

class MerchantVoucherState {
  final bool isLoading;
  final bool isCreating;
  final List<MerchantVoucher> vouchers;
  final List<Merchant> networkPartners;
  final String? errorMessage;
  final String? successMessage;

  const MerchantVoucherState({
    this.isLoading = false,
    this.isCreating = false,
    this.vouchers = const [],
    this.networkPartners = const [],
    this.errorMessage,
    this.successMessage,
  });

  MerchantVoucherState copyWith({
    bool? isLoading,
    bool? isCreating,
    List<MerchantVoucher>? vouchers,
    List<Merchant>? networkPartners,
    String? errorMessage,
    String? successMessage,
  }) {
    return MerchantVoucherState(
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      vouchers: vouchers ?? this.vouchers,
      networkPartners: networkPartners ?? this.networkPartners,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

// ==========================================
// NOTIFIER
// ==========================================

class MerchantVoucherNotifier extends Notifier<MerchantVoucherState> {
  @override
  MerchantVoucherState build() {
    return const MerchantVoucherState();
  }

  /// Tải danh sách voucher do quán phát hành
  Future<void> fetchVouchers() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await ApiClient.dio.get('/merchants/vouchers');
      final listJson = response.data as List<dynamic>;
      final vouchers = listJson
          .map((item) => MerchantVoucher.fromJson(item as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        isLoading: false,
        vouchers: vouchers,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.response?.data?['message']?.toString() ?? 'Lỗi tải danh sách voucher',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Lỗi không xác định: $e',
      );
    }
  }

  /// Tải danh sách tất cả các đối tác trong liên minh TingTing
  Future<void> fetchNetworkPartners() async {
    try {
      final response = await ApiClient.dio.get('/merchants');
      final listJson = response.data as List<dynamic>;
      final partners = listJson
          .map((item) => Merchant.fromJson(item as Map<String, dynamic>))
          .toList();
      state = state.copyWith(networkPartners: partners);
    } catch (_) {}
  }

  /// Tạo voucher mới (nội bộ hoặc liên kết đối tác)
  Future<bool> createVoucher({
    required String title,
    String? description,
    required int pointsCost,
    required int totalQuantity,
    required DateTime expiredAt,
    String? targetMerchantId,
  }) async {
    state = state.copyWith(isCreating: true, errorMessage: null, successMessage: null);

    try {
      final payload = {
        'title': title.trim(),
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
        'points_cost': pointsCost,
        'total_quantity': totalQuantity,
        'expired_at': expiredAt.toUtc().toIso8601String(),
        if (targetMerchantId != null && targetMerchantId.isNotEmpty)
          'target_merchant_id': targetMerchantId,
      };

      final response = await ApiClient.dio.post('/merchants/vouchers', data: payload);
      final newVoucherJson = response.data as Map<String, dynamic>;
      final newVoucher = MerchantVoucher.fromJson(newVoucherJson);

      // Thêm voucher mới vào đầu danh sách
      state = state.copyWith(
        isCreating: false,
        vouchers: [newVoucher, ...state.vouchers],
        successMessage: 'Tạo ưu đãi "${newVoucher.title}" thành công!',
      );

      // Cập nhật lại chỉ số báo cáo của cửa hàng
      ref.read(reportProvider.notifier).fetchDashboardData();

      return true;
    } on DioException catch (e) {
      String msg = 'Tạo ưu đãi thất bại';
      if (e.response?.data is Map && e.response?.data['message'] != null) {
        final err = e.response!.data['message'];
        msg = err is List ? err.join(', ') : err.toString();
      }
      state = state.copyWith(isCreating: false, errorMessage: msg);
      return false;
    } catch (e) {
      state = state.copyWith(isCreating: false, errorMessage: 'Lỗi: $e');
      return false;
    }
  }
}

// ==========================================
// PROVIDER
// ==========================================

final merchantVoucherProvider =
    NotifierProvider<MerchantVoucherNotifier, MerchantVoucherState>(
  MerchantVoucherNotifier.new,
);
