/// File: constants.dart
/// Module: Core
/// Description: Định nghĩa toàn bộ hằng số dùng trong Merchant App.
///
/// Responsibility:
///   - Cung cấp khóa lưu trữ SharedPreferences (Token, Thông tin Merchant)
///   - Các thông số nghiệp vụ mặc định (tỉ lệ đổi điểm, timeout)
///
/// Dependencies:
///   - Không có
///
/// Todo:
///   - [ ] Bổ sung cấu hình đa chi nhánh (multi-branch) khi mở rộng
library;

class AppConstants {
  // Storage Keys
  static const String tokenKey = 'merchant_access_token';
  static const String profileKey = 'merchant_profile_data';

  // Business Rules
  static const int defaultPointsRatio = 1000; // 1.000 VNĐ = 1 điểm VUI

  // App Name & Strings
  static const String appName = 'TingTing Merchant';
  static const String appSlogan = 'Kênh Đối Tác Quản Lý & Tích Điểm';
}
