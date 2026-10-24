/// File: merchant_auth_provider.dart
/// Module: Providers
/// Description: Quản lý trạng thái xác thực và phiên làm việc của Merchant theo Riverpod 3.0.
///
/// Responsibility:
///   - Đăng nhập qua API POST /auth/merchant/login
///   - Lưu trữ và phục hồi JWT token và thông tin cửa hàng từ SharedPreferences
///   - Cung cấp danh sách tài khoản Demo để đăng nhập nhanh 1-chạm
///   - Đăng xuất an toàn, xóa sạch session
///
/// Dependencies:
///   - package:flutter_riverpod/flutter_riverpod.dart
///   - package:shared_preferences/shared_preferences.dart
///   - app_merchant/lib/core/api_client.dart
///   - app_merchant/lib/core/constants.dart
///   - app_merchant/lib/models/merchant_model.dart
///
/// Todo:
///   - [ ] Bổ sung tính năng đổi mật khẩu cho Merchant
library;

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';
import '../core/constants.dart';
import '../models/merchant_model.dart';

// ==========================================
// TÀI KHOẢN DEMO KIỂM THỬ NHANH
// ==========================================

class DemoMerchantAccount {
  final String name;
  final String email;
  final String category;
  final String password;

  const DemoMerchantAccount({
    required this.name,
    required this.email,
    required this.category,
    this.password = '123456',
  });
}

const List<DemoMerchantAccount> demoMerchantAccounts = [
  DemoMerchantAccount(
    name: 'Highlands Coffee',
    email: 'highlands@tingting.dev',
    category: 'F&B',
  ),
  DemoMerchantAccount(
    name: 'Phúc Long Coffee & Tea',
    email: 'phuclong@tingting.dev',
    category: 'F&B',
  ),
  DemoMerchantAccount(
    name: 'The Coffee House',
    email: 'thecoffeehouse@tingting.dev',
    category: 'F&B',
  ),
  DemoMerchantAccount(
    name: 'Circle K',
    email: 'circlek@tingting.dev',
    category: 'Bán lẻ',
  ),
  DemoMerchantAccount(
    name: 'CGV Cinemas',
    email: 'cgv@tingting.dev',
    category: 'Giải trí',
  ),
];

// ==========================================
// AUTH STATE MODEL
// ==========================================

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class MerchantAuthState {
  final AuthStatus status;
  final Merchant? merchant;
  final String? errorMessage;

  const MerchantAuthState({
    this.status = AuthStatus.initial,
    this.merchant,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated && merchant != null;
  bool get isLoading => status == AuthStatus.loading;

  MerchantAuthState copyWith({
    AuthStatus? status,
    Merchant? merchant,
    String? errorMessage,
  }) {
    return MerchantAuthState(
      status: status ?? this.status,
      merchant: merchant ?? this.merchant,
      errorMessage: errorMessage,
    );
  }
}

// ==========================================
// NOTIFIER (RIVERPOD 3.0)
// ==========================================

class MerchantAuthNotifier extends Notifier<MerchantAuthState> {
  @override
  MerchantAuthState build() {
    // Tự động kiểm tra phiên đăng nhập đã lưu khi khởi tạo
    _checkStoredSession();
    return const MerchantAuthState(status: AuthStatus.initial);
  }

  Future<void> _checkStoredSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      final profileStr = prefs.getString(AppConstants.profileKey);

      if (token != null && token.isNotEmpty && profileStr != null) {
        ApiClient.setToken(token);
        final json = jsonDecode(profileStr) as Map<String, dynamic>;
        final merchant = Merchant.fromJson(json);
        state = MerchantAuthState(
          status: AuthStatus.authenticated,
          merchant: merchant,
        );
        return;
      }
    } catch (_) {}

    state = const MerchantAuthState(status: AuthStatus.unauthenticated);
  }

  /// Đăng nhập bằng Email và Mật khẩu
  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final response = await ApiClient.dio.post(
        '/auth/merchant/login',
        data: {
          'email': email.trim(),
          'password': password.trim(),
        },
      );

      final data = response.data as Map<String, dynamic>;
      final accessToken = data['access_token'] as String;
      final merchantJson = data['merchant'] as Map<String, dynamic>;
      final merchant = Merchant.fromJson(merchantJson);

      // Lưu trữ phiên vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, accessToken);
      await prefs.setString(AppConstants.profileKey, jsonEncode(merchant.toJson()));

      // Cập nhật ApiClient
      ApiClient.setToken(accessToken);

      state = MerchantAuthState(
        status: AuthStatus.authenticated,
        merchant: merchant,
      );
      return true;
    } on DioException catch (e) {
      String msg = 'Đăng nhập thất bại. Vui lòng thử lại.';
      if (e.response?.data != null && e.response?.data is Map) {
        final resData = e.response!.data as Map;
        if (resData['message'] != null) {
          msg = resData['message'].toString();
        }
      }
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: msg,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Lỗi kết nối máy chủ: $e',
      );
      return false;
    }
  }

  /// Đăng xuất và xóa sạch session
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.tokenKey);
      await prefs.remove(AppConstants.profileKey);
    } catch (_) {}

    ApiClient.setToken(null);
    state = const MerchantAuthState(status: AuthStatus.unauthenticated);
  }
}

// ==========================================
// PROVIDER
// ==========================================

final merchantAuthProvider =
    NotifierProvider<MerchantAuthNotifier, MerchantAuthState>(
  MerchantAuthNotifier.new,
);
