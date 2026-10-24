/// File: constants.dart
/// Module: Core
/// Description: Khai báo các hằng số dùng chung trong TingTing User App
///   như SharedPreferences keys, API timeouts, và cấu hình mặc định.
///
/// Responsibility:
///   - Cung cấp hằng số storage keys cho Auth token và thông tin người dùng
///   - Cung cấp cấu hình thời gian làm mới mã Dynamic QR
///
/// Dependencies:
///   - None
///
/// Todo:
///   (File đã hoàn thiện)
library;

// ==========================================
// STORAGE KEYS (SharedPreferences)
// ==========================================

class AppConstants {
  static const String tokenKey = 'tingting_access_token';
  static const String userKey = 'tingting_user_data';

  // Thời gian đếm ngược làm mới mã Dynamic QR (giây)
  static const int dynamicQrRefreshSeconds = 60;

  // Thời gian đếm ngược gửi lại OTP (giây)
  static const int otpCountdownSeconds = 60;

  // Cấu hình định dạng tiền tệ và điểm
  static const String currencySuffix = 'đ';
  static const String pointsSuffix = 'VUI';
}
