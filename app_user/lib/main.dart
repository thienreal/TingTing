/// File: main.dart
/// Module: AppRoot
/// Description: Entry point của TingTing User App. Khởi động app và cung cấp
///   demo kết nối WebSocket real-time (Task 1.5) — hiển thị SnackBar khi nhận
///   thông báo điểm từ backend.
///
/// Responsibility:
///   - Khởi tạo MaterialApp với AppTheme từ theme.dart
///   - Demo WebSocket: nhập userId → kết nối → nhận thông báo → SnackBar
///   - Giải phóng socket khi app bị đóng (dispose)
///
/// Dependencies:
///   - core/theme.dart (AppTheme, AppColors)
///   - core/socket_client.dart (SocketClient, PointsEarnedData)
///
/// Todo:
///   - [ ] Task 1.6: Thay màn hình demo bằng Auth flow (SĐT → OTP → Home)
///   - [ ] Chuyển SocketClient.connect() vào sau bước xác thực JWT thành công

import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'core/socket_client.dart';

void main() {
  runApp(const TingTingApp());
}

// ==========================================
// ROOT APP
// ==========================================

class TingTingApp extends StatelessWidget {
  const TingTingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TingTing',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const WsTestScreen(),
    );
  }
}

// ==========================================
// MÀN HÌNH DEMO WEBSOCKET (Task 1.5)
// Mục đích: test luồng kết nối real-time trước khi Task 1.6 xây dựng UI thật.
// ==========================================

class WsTestScreen extends StatefulWidget {
  const WsTestScreen({super.key});

  @override
  State<WsTestScreen> createState() => _WsTestScreenState();
}

class _WsTestScreenState extends State<WsTestScreen> {
  final TextEditingController _userIdController = TextEditingController();
  final _socketClient = SocketClient.instance;

  bool _isConnected = false;

  // ==========================================
  // VÒNG ĐỜI WIDGET
  // ==========================================

  @override
  void dispose() {
    // Luôn ngắt socket khi màn hình bị hủy để tránh memory leak
    _socketClient.disconnect();
    _userIdController.dispose();
    super.dispose();
  }

  // ==========================================
  // XỬ LÝ KẾT NỐI
  // ==========================================

  void _connect() {
    final userId = _userIdController.text.trim();
    if (userId.isEmpty) {
      _showSnackBar('⚠️ Vui lòng nhập User ID', isError: true);
      return;
    }

    // Kết nối socket và đăng ký lắng nghe sự kiện cộng điểm
    _socketClient.connect(userId);
    _socketClient.onPointsEarned(_onPointsEarned);

    setState(() => _isConnected = true);
    _showSnackBar('✅ Đang kết nối tới server...', isError: false);
  }

  void _disconnect() {
    _socketClient.disconnect();
    setState(() => _isConnected = false);
    _showSnackBar('🔌 Đã ngắt kết nối', isError: false);
  }

  // ==========================================
  // XỬ LÝ THÔNG BÁO ĐIỂM
  // ==========================================

  /// Callback khi nhận được sự kiện `points_earned` từ backend.
  /// Hiển thị SnackBar thông báo thân thiện cho user.
  void _onPointsEarned(PointsEarnedData data) {
    // Phải gọi trong main thread — dùng mounted check để an toàn
    if (!mounted) return;

    // Tạo thông báo tier upgrade nếu có lên hạng
    final tierMsg = data.tierUpgraded
        ? '\n🏆 Bạn vừa lên hạng ${data.newMembershipTier}!'
        : '';

    final message =
        '🎉 Bạn vừa nhận được ${data.pointsEarned} điểm '
        'từ ${data.merchantName}!\n'
        'Tổng điểm: ${data.newTotalPoints}$tierMsg';

    _showSnackBar(message, isError: false, duration: const Duration(seconds: 5));
  }

  // ==========================================
  // HELPER: SnackBar
  // ==========================================

  void _showSnackBar(
    String message, {
    required bool isError,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: isError ? AppColors.action : AppColors.textPrimary,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ==========================================
  // BUILD UI
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'TingTing — Test WebSocket',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==========================================
            // TRẠNG THÁI KẾT NỐI
            // ==========================================
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: _isConnected
                    ? Colors.green.shade50
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isConnected ? Colors.green : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isConnected ? Icons.wifi : Icons.wifi_off,
                    color: _isConnected ? Colors.green : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isConnected ? 'Đang kết nối WebSocket' : 'Chưa kết nối',
                    style: TextStyle(
                      color: _isConnected
                          ? Colors.green.shade700
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==========================================
            // NHẬP USER ID
            // ==========================================
            Text(
              'User ID (UUID)',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _userIdController,
              enabled: !_isConnected,
              decoration: InputDecoration(
                hintText: 'Dán UUID của user vào đây',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ==========================================
            // NÚT KẾT NỐI / NGẮT
            // ==========================================
            ElevatedButton(
              onPressed: _isConnected ? _disconnect : _connect,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isConnected ? AppColors.action : AppColors.primary,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _isConnected ? 'Ngắt kết nối' : 'Kết nối WebSocket',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ==========================================
            // HƯỚNG DẪN TEST
            // ==========================================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📋 Cách test:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. Chạy backend: npm run start:dev\n'
                    '2. Nhập User ID (UUID) vào ô trên\n'
                    '3. Nhấn "Kết nối WebSocket"\n'
                    '4. Gọi POST /points/earn qua Postman\n'
                    '5. Xem SnackBar xuất hiện!',
                    style: TextStyle(color: AppColors.textSecondary, height: 1.6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
