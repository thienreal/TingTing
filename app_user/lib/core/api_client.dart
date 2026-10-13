/// File: api_client.dart
/// Module: Core
/// Description: Cung cấp Base URL kết nối tới Backend API cho các môi trường khác nhau.
///
/// Responsibility:
///   - Tự động nhận diện nền tảng (Web/Desktop/Android Emulator) để trả về Base URL thích hợp
///
/// Dependencies:
///   - package:flutter/foundation.dart
///
/// Todo:

import 'package:flutter/foundation.dart';

class ApiClient {
  static String getBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      // 10.0.2.2 trỏ về localhost máy host từ Android Emulator
      return 'http://10.0.2.2:3000';
    }
    // Mặc định cho Linux, macOS, Windows desktop
    return 'http://localhost:3000';
  }
}
