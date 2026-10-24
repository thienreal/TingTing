/// File: main.dart
/// Module: Main
/// Description: Điểm khởi chạy chính của TingTing Merchant App (Ứng dụng cho Đối Tác/Cửa Hàng).
///
/// Responsibility:
///   - Khởi tạo Flutter Engine & cấu hình ProviderScope của Riverpod
///   - Thiết lập MaterialApp.router với cấu hình GoRouter tập trung
///   - Áp dụng AppTheme theo chuẩn UI_Design_Rules
///
/// Dependencies:
///   - package:flutter/material.dart
///   - package:flutter_riverpod/flutter_riverpod.dart
///   - app_merchant/lib/core/theme.dart
///   - app_merchant/lib/core/router.dart
///
/// Todo:
///   - [ ] Bổ sung crash reporting (Sentry/Firebase Crashlytics) khi đưa lên production
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MerchantApp(),
    ),
  );
}

class MerchantApp extends ConsumerWidget {
  const MerchantApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'TingTing Merchant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
