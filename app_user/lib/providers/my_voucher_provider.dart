/// File: my_voucher_provider.dart
/// Module: Providers
/// Description: Quản lý danh sách voucher cá nhân mà người dùng đã đổi,
///   và xử lý hành động đổi voucher (Redeem) từ sàn ưu đãi.
///
/// Responsibility:
///   - Gọi API GET /vouchers/mine tải danh sách voucher cá nhân
///   - Phân loại voucher: Đang có (ACTIVE), Đã dùng (USED), Hết hạn (EXPIRED)
///   - Gọi API POST /vouchers/:id/redeem đổi điểm lấy voucher và cập nhật số dư điểm
///
/// Dependencies:
///   - package:flutter_riverpod/flutter_riverpod.dart
///   - app_user/lib/core/api_client.dart
///   - app_user/lib/models/user_voucher_model.dart
///   - app_user/lib/providers/user_provider.dart
///
/// Todo:
///   (File đã hoàn thiện)
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/user_voucher_model.dart';
import 'user_provider.dart';
import 'auth_provider.dart';

// ==========================================
// MY VOUCHER STATE
// ==========================================

class MyVoucherState {
  final List<UserVoucherModel> vouchers;
  final bool isLoading;
  final bool isRedeeming;
  final String? error;

  const MyVoucherState({
    this.vouchers = const [],
    this.isLoading = false,
    this.isRedeeming = false,
    this.error,
  });

  /// Danh sách voucher đang có hiệu lực (chưa dùng)
  List<UserVoucherModel> get activeVouchers =>
      vouchers.where((v) => v.status == 'ACTIVE' && !(v.voucher?.isExpired ?? false)).toList();

  /// Danh sách voucher đã sử dụng tại cửa hàng
  List<UserVoucherModel> get usedVouchers =>
      vouchers.where((v) => v.status == 'USED').toList();

  /// Danh sách voucher đã hết hạn sử dụng
  List<UserVoucherModel> get expiredVouchers =>
      vouchers.where((v) => v.status == 'EXPIRED' || (v.voucher?.isExpired ?? false)).toList();

  MyVoucherState copyWith({
    List<UserVoucherModel>? vouchers,
    bool? isLoading,
    bool? isRedeeming,
    String? error,
  }) {
    return MyVoucherState(
      vouchers: vouchers ?? this.vouchers,
      isLoading: isLoading ?? this.isLoading,
      isRedeeming: isRedeeming ?? this.isRedeeming,
      error: error,
    );
  }
}

// ==========================================
// MY VOUCHER NOTIFIER (RIVERPOD 3 NOTIFIER)
// ==========================================

class MyVoucherNotifier extends Notifier<MyVoucherState> {
  @override
  MyVoucherState build() {
    // Tự động tải danh sách voucher cá nhân khi người dùng đã xác thực
    final isAuth = ref.watch(authProvider.select((s) => s.isAuthenticated));
    if (isAuth) {
      Future.microtask(() => loadMyVouchers());
    }
    return const MyVoucherState();
  }

  /// Tải danh sách voucher cá nhân từ GET /vouchers/mine
  Future<void> loadMyVouchers() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await ApiClient.dio.get('/vouchers/mine');
      if (response.statusCode == 200) {
        final list = (response.data as List)
            .map((item) => UserVoucherModel.fromJson(item as Map<String, dynamic>))
            .toList();
        state = state.copyWith(vouchers: list, isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Không thể tải voucher của bạn');
    }
  }

  /// Đổi điểm lấy voucher qua POST /vouchers/:id/redeem
  /// Trả về Map kết quả: {'success': bool, 'message': String, 'voucher': UserVoucherModel?}
  Future<Map<String, dynamic>> redeemVoucher(String voucherId) async {
    state = state.copyWith(isRedeeming: true);

    try {
      final response = await ApiClient.dio.post('/vouchers/$voucherId/redeem');

      if (response.statusCode == 200) {
        final userVoucher = UserVoucherModel.fromJson(response.data as Map<String, dynamic>);
        
        // Cập nhật lại danh sách voucher cá nhân
        state = state.copyWith(
          vouchers: [userVoucher, ...state.vouchers],
          isRedeeming: false,
        );

        // Đồng bộ lại số dư điểm của người dùng
        ref.read(userProvider.notifier).loadProfile();

        return {
          'success': true,
          'message': 'Đổi voucher thành công!',
          'voucher': userVoucher,
        };
      }
      throw Exception('Lỗi xử lý đổi voucher');
    } on DioException catch (e) {
      state = state.copyWith(isRedeeming: false);
      final msg = e.response?.data?['message'] ?? 'Không đủ điểm hoặc voucher đã hết số lượng';
      return {
        'success': false,
        'message': msg.toString(),
      };
    } catch (_) {
      state = state.copyWith(isRedeeming: false);
      return {
        'success': false,
        'message': 'Đã có lỗi xảy ra, vui lòng thử lại sau',
      };
    }
  }
}

// ==========================================
// PROVIDER KHỞI TẠO
// ==========================================

final myVoucherProvider = NotifierProvider<MyVoucherNotifier, MyVoucherState>(MyVoucherNotifier.new);
