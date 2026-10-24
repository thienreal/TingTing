/// File: api_client.dart
/// Module: Core
/// Description: Cung cấp Base URL và Singleton Dio instance kết nối tới Backend API cho Merchant App.
///   Tự động đính kèm JWT Bearer Token vào header của mọi request khi đã đăng nhập.
///
/// Responsibility:
///   - Tự động nhận diện nền tảng (Web/Desktop/Android Emulator) để trả về Base URL thích hợp
///   - Cung cấp Dio client có cấu hình timeout và Auth Interceptor
///   - Lưu trữ và cập nhật Merchant Auth Token trong bộ nhớ và SharedPreferences
///
/// Dependencies:
///   - package:dio/dio.dart
///   - package:flutter/foundation.dart
///   - package:shared_preferences/shared_preferences.dart
///   - app_merchant/lib/core/constants.dart
///
/// Todo:
///   - [ ] Bổ sung Refresh Token interceptor khi backend triển khai refresh flow
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

// ==========================================
// API CLIENT SINGLETON
// ==========================================

class ApiClient {
  static Dio? _dio;
  static String? _token;

  /// Địa chỉ IP LAN hoặc host tùy chỉnh (VD: '192.168.1.15' hoặc '127.0.0.1' khi dùng adb reverse).
  /// Nếu để null: mặc định tự nhận diện Android Emulator (10.0.2.2) hoặc localhost (Desktop/Web).
  static String? customServerHost;

  /// Lấy Base URL phụ thuộc vào môi trường chạy.
  static String getBaseUrl() {
    if (customServerHost != null && customServerHost!.isNotEmpty) {
      return 'http://$customServerHost:3000';
    }
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      // 10.0.2.2 trỏ về localhost máy host từ Android Emulator
      return 'http://10.0.2.2:3000';
    }
    // Mặc định cho Linux, macOS, Windows desktop, iOS simulator
    return 'http://localhost:3000';
  }

  /// Cập nhật token đang sử dụng trong bộ nhớ và Dio header
  static void setToken(String? token) {
    _token = token;
  }

  /// Lấy token hiện tại
  static String? get token => _token;

  /// Khởi tạo và trả về singleton Dio instance
  static Dio get dio {
    if (_dio != null) return _dio!;

    final options = BaseOptions(
      baseUrl: getBaseUrl(),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio = Dio(options);

    // ==========================================
    // INTERCEPTOR TỰ ĐỘNG GẮN BEARER TOKEN
    // ==========================================
    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Nếu trong memory chưa có token, thử đọc từ SharedPreferences
          if (_token == null) {
            try {
              final prefs = await SharedPreferences.getInstance();
              _token = prefs.getString(AppConstants.tokenKey);
            } catch (_) {}
          }

          if (_token != null && _token!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // Log lỗi request để debug môi trường dev
          if (kDebugMode) {
            print('[Merchant ApiClient Error] ${error.requestOptions.path} -> ${error.response?.statusCode}: ${error.response?.data}');
          }
          return handler.next(error);
        },
      ),
    );

    return _dio!;
  }
}
