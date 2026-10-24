/// File: voucher_provider.dart
/// Module: Providers
/// Description: Quản lý danh sách voucher từ sàn ưu đãi TingTing,
///   hỗ trợ tìm kiếm, lọc theo ngành hàng và phân loại hiển thị.
///
/// Responsibility:
///   - Gọi API GET /vouchers lấy toàn bộ voucher còn tồn kho
///   - Lọc voucher theo category (Tất cả, Ẩm thực, Giải trí, Mua sắm...)
///   - Lọc theo từ khóa tìm kiếm (search query)
///
/// Dependencies:
///   - package:flutter_riverpod/flutter_riverpod.dart
///   - app_user/lib/core/api_client.dart
///   - app_user/lib/models/voucher_model.dart
///
/// Todo:
///   (File đã hoàn thiện)
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/voucher_model.dart';
import 'auth_provider.dart';

// ==========================================
// VOUCHER STATE
// ==========================================

class VoucherState {
  final List<VoucherModel> allVouchers;
  final bool isLoading;
  final String? error;
  final String selectedCategory;
  final String searchQuery;

  const VoucherState({
    this.allVouchers = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory = 'Tất cả',
    this.searchQuery = '',
  });

  /// Danh sách voucher sau khi lọc theo Danh mục và Từ khóa tìm kiếm
  List<VoucherModel> get filteredVouchers {
    return allVouchers.where((v) {
      // Lọc theo Category
      if (selectedCategory != 'Tất cả') {
        final cat = v.merchant?.category ?? '';
        if (selectedCategory == 'Ẩm thực' && !(cat.contains('F&B') || cat.contains('Ẩm thực'))) {
          return false;
        }
        if (selectedCategory == 'Mua sắm' && !(cat.contains('Bán lẻ') || cat.contains('Mua sắm'))) {
          return false;
        }
        if (selectedCategory == 'Giải trí' && !(cat.contains('Giải trí') || cat.contains('Dịch vụ'))) {
          return false;
        }
      }

      // Lọc theo Search Query
      if (searchQuery.trim().isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchTitle = v.title.toLowerCase().contains(query);
        final matchMerchant = v.merchantName.toLowerCase().contains(query);
        return matchTitle || matchMerchant;
      }

      return true;
    }).toList();
  }

  /// Danh sách ưu đãi mới cập bến
  List<VoucherModel> get newVouchers => allVouchers.take(5).toList();

  /// Danh sách deal ẩm thực
  List<VoucherModel> get foodDeals => allVouchers
      .where((v) => (v.merchant?.category?.contains('F&B') ?? false) || v.title.toLowerCase().contains('bánh') || v.title.toLowerCase().contains('pizza'))
      .toList();

  VoucherState copyWith({
    List<VoucherModel>? allVouchers,
    bool? isLoading,
    String? error,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return VoucherState(
      allVouchers: allVouchers ?? this.allVouchers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// ==========================================
// VOUCHER NOTIFIER (RIVERPOD 3 NOTIFIER)
// ==========================================

class VoucherNotifier extends Notifier<VoucherState> {
  @override
  VoucherState build() {
    // Tự động tải danh sách voucher khi người dùng đã xác thực
    final isAuth = ref.watch(authProvider.select((s) => s.isAuthenticated));
    if (isAuth) {
      Future.microtask(() => loadVouchers());
    }
    return const VoucherState();
  }

  /// Tải toàn bộ voucher từ backend
  Future<void> loadVouchers() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await ApiClient.dio.get('/vouchers');
      if (response.statusCode == 200) {
        final list = (response.data as List)
            .map((item) => VoucherModel.fromJson(item as Map<String, dynamic>))
            .toList();
        state = state.copyWith(allVouchers: list, isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Không thể tải danh sách ưu đãi');
    }
  }

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

// ==========================================
// PROVIDER KHỞI TẠO
// ==========================================

final voucherProvider = NotifierProvider<VoucherNotifier, VoucherState>(VoucherNotifier.new);
