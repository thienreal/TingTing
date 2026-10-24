/// File: auth_provider.dart
/// Module: Providers
/// Description: Riverpod Notifier quản lý toàn bộ luồng xác thực của User App:
///   Gửi OTP, xác thực Mock OTP, lưu JWT vào SharedPreferences và kết nối WebSocket.
///
/// Responsibility:
///   - Quản lý trạng thái AuthState (đã đăng nhập, token, user profile, loading, error)
///   - Tự động khôi phục phiên đăng nhập khi mở app
///   - Tự động kích hoạt SocketClient kết nối với userId khi đăng nhập thành công
///   - Xóa token và ngắt socket khi đăng xuất
///
/// Dependencies:
///   - package:flutter_riverpod/flutter_riverpod.dart
///   - package:shared_preferences/shared_preferences.dart
///   - app_user/lib/core/api_client.dart
///   - app_user/lib/core/constants.dart
///   - app_user/lib/core/socket_client.dart
///   - app_user/lib/models/user_model.dart
///
/// Todo:
///   (File đã hoàn thiện)
library;

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';
import '../core/constants.dart';
import '../core/socket_client.dart';
import '../models/user_model.dart';

// ==========================================
// AUTH STATE
// ==========================================

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? token;
  final UserModel? user;
  final String? currentPhoneNumber;
  final String? errorMessage;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.token,
    this.user,
    this.currentPhoneNumber,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? token,
    UserModel? user,
    String? currentPhoneNumber,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
      user: user ?? this.user,
      currentPhoneNumber: currentPhoneNumber ?? this.currentPhoneNumber,
      errorMessage: errorMessage,
    );
  }
}

// ==========================================
// AUTH NOTIFIER (RIVERPOD 3 NOTIFIER)
// ==========================================

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    checkAuthStatus();
    return const AuthState();
  }

  /// Kiểm tra xem đã có token và profile lưu trong máy chưa
  Future<void> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      final userJsonStr = prefs.getString(AppConstants.userKey);

      if (token != null && token.isNotEmpty && userJsonStr != null) {
        ApiClient.setToken(token);
        final userMap = jsonDecode(userJsonStr) as Map<String, dynamic>;
        final user = UserModel.fromJson(userMap);

        state = state.copyWith(
          isAuthenticated: true,
          token: token,
          user: user,
        );

        // Kích hoạt kết nối Socket real-time cho User này
        SocketClient.instance.connect(user.id);
      }
    } catch (_) {
      // Bỏ qua lỗi đọc cache, giữ trạng thái chưa đăng nhập
    }
  }

  /// Gửi OTP tới số điện thoại (MVP sinh Mock OTP 000000)
  Future<bool> sendOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await ApiClient.dio.post(
        '/auth/send-otp',
        data: {'phone_number': phoneNumber},
      );

      if (response.statusCode == 200) {
        state = state.copyWith(
          isLoading: false,
          currentPhoneNumber: phoneNumber,
        );
        return true;
      }
      throw Exception('Không thể gửi mã OTP');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Số điện thoại không hợp lệ hoặc lỗi kết nối',
      );
      return false;
    }
  }

  /// Xác thực mã OTP và nhận Access Token
  Future<bool> verifyOtp(String otp) async {
    final phone = state.currentPhoneNumber;
    if (phone == null) {
      state = state.copyWith(errorMessage: 'Vui lòng nhập lại số điện thoại');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await ApiClient.dio.post(
        '/auth/verify-otp',
        data: {
          'phone_number': phone,
          'otp': otp,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final accessToken = data['access_token'] as String;
        final userMap = data['user'] as Map<String, dynamic>;
        final user = UserModel.fromJson(userMap);

        // Lưu vào SharedPreferences để ghi nhớ phiên
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.tokenKey, accessToken);
        await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));

        ApiClient.setToken(accessToken);

        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          token: accessToken,
          user: user,
        );

        // Kết nối WebSocket real-time ngay sau khi đăng nhập thành công
        SocketClient.instance.connect(user.id);

        return true;
      }
      throw Exception('Mã OTP không chính xác');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Mã OTP không chính xác (Thử dùng mã "000000")',
      );
      return false;
    }
  }

  /// Cập nhật user model cục bộ (ví dụ khi điểm thay đổi qua WebSocket)
  void updateUser(UserModel updatedUser) {
    state = state.copyWith(user: updatedUser);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(AppConstants.userKey, jsonEncode(updatedUser.toJson()));
    });
  }

  /// Đăng xuất khỏi ứng dụng
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.tokenKey);
      await prefs.remove(AppConstants.userKey);
    } catch (_) {}

    ApiClient.setToken(null);
    SocketClient.instance.disconnect();

    state = const AuthState(isAuthenticated: false);
  }
}

// ==========================================
// PROVIDER KHỞI TẠO
// ==========================================

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
