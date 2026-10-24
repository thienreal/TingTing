/// File: router.dart
/// Module: Core
/// Description: Cấu hình điều hướng tập trung toàn bộ User App bằng GoRouter,
///   hỗ trợ Auth Redirect Guard và 4 Tab Bottom Navigation qua StatefulShellRoute.
///
/// Responsibility:
///   - Quản lý tất cả route URL trong ứng dụng
///   - Tự động bảo vệ các màn hình yêu cầu xác thực (Auth Guard)
///   - Kết nối với Riverpod Provider để cập nhật khi trạng thái Auth thay đổi
///
/// Dependencies:
///   - package:go_router/go_router.dart
///   - package:flutter_riverpod/flutter_riverpod.dart
///   - app_user/lib/providers/auth_provider.dart
///   - app_user/lib/screens/...
///
/// Todo:
///   (File đã hoàn thiện)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/main_shell.dart';
import '../screens/auth/phone_input_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/earn/earn_points_screen.dart';
import '../screens/rewards/rewards_screen.dart';
import '../screens/rewards/voucher_detail_screen.dart';
import '../screens/my_vouchers/my_vouchers_screen.dart';
import '../screens/my_vouchers/my_voucher_barcode_screen.dart';
import '../screens/account/account_screen.dart';
import '../screens/account/transaction_history_screen.dart';

// Khóa GlobalKey cho Navigator
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _earnNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'earn');
final _rewardsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rewards');
final _accountNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'account');

/// Notifier quản lý trigger redirect cho GoRouter mà không re-create instance GoRouter
/// khi các trường tạm thời (isLoading, errorMessage) của AuthState thay đổi.
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<bool>(
      authProvider.select((state) => state.isAuthenticated),
      (previous, next) {
        if (previous != next) {
          notifyListeners();
        }
      },
    );
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final isAuth = _ref.read(authProvider).isAuthenticated;
    final isLoggingIn = state.matchedLocation.startsWith('/auth');

    // Nếu chưa đăng nhập và không ở màn hình auth -> điều hướng về nhập số điện thoại
    if (!isAuth && !isLoggingIn) {
      return '/auth/phone';
    }

    // Nếu đã đăng nhập mà đang ở màn hình auth -> điều hướng về trang chủ
    if (isAuth && isLoggingIn) {
      return '/home';
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
    initialLocation: '/home',
    refreshListenable: routerNotifier,
    redirect: routerNotifier.redirect,
    routes: [
      // ==========================================
      // NHÁNH XÁC THỰC (AUTH)
      // ==========================================
      GoRoute(
        path: '/auth/phone',
        builder: (context, state) => const PhoneInputScreen(),
      ),
      GoRoute(
        path: '/auth/otp',
        builder: (context, state) => const OtpScreen(),
      ),

      // ==========================================
      // NHÁNH CHÍNH (4 TABS SHELL)
      // ==========================================
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // Tab 1: Trang chủ
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Tab 2: Tích điểm (Dynamic QR)
          StatefulShellBranch(
            navigatorKey: _earnNavigatorKey,
            routes: [
              GoRoute(
                path: '/earn',
                builder: (context, state) => const EarnPointsScreen(),
              ),
            ],
          ),

          // Tab 3: Đổi thưởng (Marketplace)
          StatefulShellBranch(
            navigatorKey: _rewardsNavigatorKey,
            routes: [
              GoRoute(
                path: '/rewards',
                builder: (context, state) => const RewardsScreen(),
              ),
            ],
          ),

          // Tab 4: Tài khoản
          StatefulShellBranch(
            navigatorKey: _accountNavigatorKey,
            routes: [
              GoRoute(
                path: '/account',
                builder: (context, state) => const AccountScreen(),
              ),
            ],
          ),
        ],
      ),

      // ==========================================
      // CÁC MÀN HÌNH CHI TIẾT (FULL SCREEN)
      // ==========================================
      GoRoute(
        path: '/voucher/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return VoucherDetailScreen(voucherId: id);
        },
      ),
      GoRoute(
        path: '/my-vouchers',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MyVouchersScreen(),
      ),
      GoRoute(
        path: '/my-voucher/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return MyVoucherBarcodeScreen(userVoucherId: id);
        },
      ),
      GoRoute(
        path: '/transactions',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TransactionHistoryScreen(),
      ),
    ],
  );
});
