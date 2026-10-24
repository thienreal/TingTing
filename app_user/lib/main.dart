/// File: main.dart
/// Module: AppRoot
/// Description: Entry point chính thức của TingTing User App.
///   Khởi tạo ProviderScope của Riverpod, kết nối GoRouter, áp dụng ThemeData
///   và quản lý lắng nghe sự kiện WebSocket real-time toàn ứng dụng.
///
/// Responsibility:
///   - Khởi tạo MaterialApp.router với AppTheme và routerProvider
///   - Bọc toàn bộ ứng dụng trong ProviderScope để quản lý state tập trung
///   - Lắng nghe sự kiện WebSocket points_earned để tự động cập nhật số dư điểm
///     và hiển thị thông báo chúc mừng trực tiếp trên màn hình
///
/// Dependencies:
///   - package:flutter/material.dart
///   - package:flutter_riverpod/flutter_riverpod.dart
///   - core/theme.dart (AppTheme, AppColors)
///   - core/router.dart (routerProvider)
///   - core/socket_client.dart (SocketClient, PointsEarnedData)
///   - providers/user_provider.dart
///
/// Todo:
///   (File đã hoàn thiện theo Task 1.6)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'core/socket_client.dart';
import 'providers/user_provider.dart';
import 'providers/my_voucher_provider.dart';

// Global Key cho ScaffoldMessenger để hiển thị SnackBar / Banner từ bất kỳ đâu
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: TingTingApp(),
    ),
  );
}

// ==========================================
// ROOT APP WIDGET
// ==========================================

class TingTingApp extends ConsumerStatefulWidget {
  const TingTingApp({super.key});

  @override
  ConsumerState<TingTingApp> createState() => _TingTingAppState();
}

class _TingTingAppState extends ConsumerState<TingTingApp> {
  final _socketClient = SocketClient.instance;

  @override
  void initState() {
    super.initState();
    _setupWebSocketListener();
  }

  /// Lắng nghe sự kiện cộng điểm real-time từ backend qua Socket.IO (Port 3001)
  void _setupWebSocketListener() {
    _socketClient.onPointsEarned((PointsEarnedData data) {
      if (!mounted) return;

      // 1. Cập nhật số dư điểm mới vào Riverpod state
      ref.read(userProvider.notifier).updatePointsFromSocket(
            newTotalPoints: data.newTotalPoints,
            newMembershipTier: data.newMembershipTier,
          );

      // 2. Hiển thị thông báo nổi chúc mừng trực tiếp trên màn hình
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('✦', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎉 +${data.pointsEarned} điểm VUI!',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Từ: ${data.merchantName} · Tổng: ${data.newTotalPoints} VUI (${data.newMembershipTier})',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.textPrimary,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
    });

    // 2. Lắng nghe sự kiện voucher_used khi thu ngân quét áp dụng voucher
    _socketClient.onVoucherUsed((VoucherUsedData data) {
      if (!mounted) return;

      // Tự động tải lại danh sách voucher để cập nhật trạng thái sang Đã dùng
      ref.read(myVoucherProvider.notifier).loadMyVouchers();

      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.action,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.check_circle_outline, color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🎫 Voucher đã áp dụng thành công!',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${data.voucherTitle} tại ${data.merchantName}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.textPrimary,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
    });
  }

  @override
  void dispose() {
    _socketClient.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'TingTing',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
    );
  }
}
