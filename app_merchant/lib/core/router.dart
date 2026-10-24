/// File: router.dart
/// Module: Core
/// Description: Cấu hình điều hướng tập trung toàn bộ Merchant App bằng GoRouter,
///   hỗ trợ Auth Redirect Guard và 4 Tab Bottom Navigation qua StatefulShellRoute.
///
/// Responsibility:
///   - Quản lý tất cả route URL trong ứng dụng
///   - Tự động bảo vệ các màn hình yêu cầu xác thực (Auth Guard)
///   - Kết nối với Riverpod Provider để cập nhật khi trạng thái Auth thay đổi mà không tạo loop
///
/// Dependencies:
///   - package:go_router/go_router.dart
///   - package:flutter_riverpod/flutter_riverpod.dart
///   - app_merchant/lib/providers/merchant_auth_provider.dart
///   - app_merchant/lib/screens/...
///
/// Todo:
///   - [ ] Bổ sung deep-link cho tính năng quét mã trực tiếp từ POS
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/merchant_auth_provider.dart';
import '../screens/main_shell.dart';
import '../screens/auth/merchant_login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/scan/scan_screen.dart';
import '../screens/vouchers/merchant_vouchers_screen.dart';
import '../screens/vouchers/create_voucher_screen.dart';
import '../screens/account/merchant_account_screen.dart';

// Navigator Keys
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'merchant_root');
final _dashboardNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'dashboard');
final _scanNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'scan');
final _vouchersNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'vouchers');
final _accountNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'account');

/// RouterNotifier quản lý redirect lắng nghe thay đổi xác thực
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<bool>(
      merchantAuthProvider.select((state) => state.isAuthenticated),
      (previous, next) {
        if (previous != next) {
          notifyListeners();
        }
      },
    );
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final isAuth = _ref.read(merchantAuthProvider).isAuthenticated;
    final isLoggingIn = state.matchedLocation == '/login';

    // Nếu chưa đăng nhập và không ở màn hình login -> chuyển về /login
    if (!isAuth && !isLoggingIn) {
      return '/login';
    }

    // Nếu đã đăng nhập mà đang ở màn hình login -> chuyển về /dashboard
    if (isAuth && isLoggingIn) {
      return '/dashboard';
    }

    return null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final routerNotifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    refreshListenable: routerNotifier,
    redirect: routerNotifier.redirect,
    routes: [
      // ==========================================
      // ROUTE ĐĂNG NHẬP
      // ==========================================
      GoRoute(
        path: '/login',
        builder: (context, state) => const MerchantLoginScreen(),
      ),

      // ==========================================
      // ROUTE TẠO VOUCHER MỚI (TOÀN MÀN HÌNH)
      // ==========================================
      GoRoute(
        path: '/vouchers/create',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateVoucherScreen(),
      ),

      // ==========================================
      // NHÁNH CHÍNH (4 TABS SHELL)
      // ==========================================
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0: Dashboard Tổng quan
          StatefulShellBranch(
            navigatorKey: _dashboardNavigatorKey,
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          // Tab 1: Quét mã giao dịch
          StatefulShellBranch(
            navigatorKey: _scanNavigatorKey,
            routes: [
              GoRoute(
                path: '/scan',
                builder: (context, state) => const ScanScreen(),
              ),
            ],
          ),

          // Tab 2: Quản lý Voucher
          StatefulShellBranch(
            navigatorKey: _vouchersNavigatorKey,
            routes: [
              GoRoute(
                path: '/vouchers',
                builder: (context, state) => const MerchantVouchersScreen(),
              ),
            ],
          ),

          // Tab 3: Quầy & Cài đặt tài khoản
          StatefulShellBranch(
            navigatorKey: _accountNavigatorKey,
            routes: [
              GoRoute(
                path: '/account',
                builder: (context, state) => const MerchantAccountScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
