/// File: user_provider.dart
/// Module: Providers
/// Description: Quản lý thông tin chi tiết của người dùng, số dư điểm,
///   hạng thành viên và danh sách lịch sử giao dịch.
///
/// Responsibility:
///   - Tải thông tin cá nhân mới nhất từ GET /users/me
///   - Tải danh sách giao dịch tích - đổi từ GET /users/me/transactions
///   - Cung cấp hàm đồng bộ điểm khi nhận thông báo WebSocket
///
/// Dependencies:
///   - package:flutter_riverpod/flutter_riverpod.dart
///   - app_user/lib/core/api_client.dart
///   - app_user/lib/models/user_model.dart
///   - app_user/lib/models/transaction_model.dart
///   - app_user/lib/providers/auth_provider.dart
///
/// Todo:
///   (File đã hoàn thiện)
library;

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';
import '../core/constants.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import 'auth_provider.dart';

// ==========================================
// USER STATE
// ==========================================

class UserState {
  final UserModel? user;
  final List<TransactionModel> transactions;
  final bool isLoading;
  final bool isTransactionsLoading;
  final String? error;

  const UserState({
    this.user,
    this.transactions = const [],
    this.isLoading = false,
    this.isTransactionsLoading = false,
    this.error,
  });

  UserState copyWith({
    UserModel? user,
    List<TransactionModel>? transactions,
    bool? isLoading,
    bool? isTransactionsLoading,
    String? error,
  }) {
    return UserState(
      user: user ?? this.user,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      isTransactionsLoading: isTransactionsLoading ?? this.isTransactionsLoading,
      error: error,
    );
  }
}

// ==========================================
// USER NOTIFIER (RIVERPOD 3 NOTIFIER)
// ==========================================

class UserNotifier extends Notifier<UserState> {
  @override
  UserState build() {
    // Chỉ kích hoạt khi trạng thái đăng nhập là true
    final isAuth = ref.watch(authProvider.select((s) => s.isAuthenticated));
    if (isAuth) {
      final initialUser = ref.read(authProvider).user;
      Future.microtask(() {
        loadProfile();
        loadTransactions();
      });
      return UserState(user: initialUser);
    }
    return const UserState();
  }

  /// Tải thông tin người dùng từ GET /users/me
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await ApiClient.dio.get('/users/me');
      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data as Map<String, dynamic>);
        state = state.copyWith(user: user, isLoading: false);
        // Lưu thông tin người dùng cục bộ mà không trigger vòng lặp authProvider
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
        } catch (_) {}
      }
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Không thể tải thông tin tài khoản');
    }
  }

  /// Tải danh sách giao dịch từ GET /users/me/transactions
  Future<void> loadTransactions() async {
    state = state.copyWith(isTransactionsLoading: true);

    try {
      final response = await ApiClient.dio.get('/users/me/transactions');
      if (response.statusCode == 200) {
        final list = (response.data as List)
            .map((item) => TransactionModel.fromJson(item as Map<String, dynamic>))
            .toList();
        state = state.copyWith(transactions: list, isTransactionsLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isTransactionsLoading: false);
    }
  }

  /// Cập nhật điểm và hạng ngay khi nhận event WebSocket points_earned
  void updatePointsFromSocket({
    required int newTotalPoints,
    required String newMembershipTier,
  }) {
    if (state.user != null) {
      final updatedUser = state.user!.copyWith(
        totalPoints: newTotalPoints,
        membershipTier: newMembershipTier,
      );
      state = state.copyWith(user: updatedUser);
      ref.read(authProvider.notifier).updateUser(updatedUser);
      // Tải lại lịch sử giao dịch để hiển thị giao dịch cộng điểm mới
      loadTransactions();
    }
  }
}

// ==========================================
// PROVIDER KHỞI TẠO
// ==========================================

final userProvider = NotifierProvider<UserNotifier, UserState>(UserNotifier.new);
