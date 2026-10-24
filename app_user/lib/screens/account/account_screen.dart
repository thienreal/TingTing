/// File: account_screen.dart
/// Module: AccountFeature
/// Description: Màn hình Quản lý Tài khoản & Hồ sơ của User App TingTing.
///   Thiết kế chuẩn theo mẫu anh/852e925bc5e044be1df124.jpg.
///
/// Responsibility:
///   - Hiển thị avatar, tên người dùng, số điện thoại, hạng thành viên
///   - Các lối tắt: Lịch sử tích - đổi, Ưu đãi của bạn, Đăng xuất
///
/// Dependencies:
///   - package:flutter/material.dart
///   - package:flutter_riverpod/flutter_riverpod.dart
///   - package:go_router/go_router.dart
///   - app_user/lib/core/theme.dart (AppColors)
///   - app_user/lib/providers/user_provider.dart
///   - app_user/lib/providers/auth_provider.dart
///
/// Todo:
///   (File đã hoàn thiện)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final user = userState.user;

    final displayName = user?.displayName ?? 'Thành viên TingTing';
    final phone = user?.phoneNumber ?? '---';
    final tier = user?.membershipTier ?? 'STANDARD';
    final totalPoints = user?.totalPoints ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ==========================================
          // HEADER HỒ SƠ CÁ NHÂN VÀNG
          // ==========================================
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFF9DB), AppColors.primaryLight],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🐤', style: TextStyle(fontSize: 32)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          phone,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '⭐ Hạng $tier · $totalPoints VUI',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ==========================================
          // DANH SÁCH MENU TIỆN ÍCH
          // ==========================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.history_rounded,
                      title: 'Lịch sử tích - đổi',
                      onTap: () => context.push('/transactions'),
                    ),
                    const Divider(height: 1, indent: 56, color: AppColors.border),
                    _buildMenuItem(
                      icon: Icons.confirmation_number_outlined,
                      title: 'Ưu đãi của bạn',
                      onTap: () => context.push('/my-vouchers'),
                    ),
                    const Divider(height: 1, indent: 56, color: AppColors.border),
                    _buildMenuItem(
                      icon: Icons.qr_code_rounded,
                      title: 'Mã thành viên của tôi',
                      onTap: () => context.go('/earn'),
                    ),
                    const Divider(height: 1, indent: 56, color: AppColors.border),
                    _buildMenuItem(
                      icon: Icons.info_outline_rounded,
                      title: 'Về ứng dụng TingTing',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('TingTing — Nền tảng ví tích điểm thưởng đa thương hiệu v1.0'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 56, color: AppColors.border),
                    _buildMenuItem(
                      icon: Icons.logout_rounded,
                      title: 'Đăng xuất tài khoản',
                      iconColor: AppColors.action,
                      titleColor: AppColors.action,
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text('Đăng xuất'),
                            content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.action),
                                child: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await ref.read(authProvider.notifier).logout();
                          if (context.mounted) {
                            context.go('/auth/phone');
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = AppColors.textPrimary,
    Color titleColor = AppColors.textPrimary,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 24),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: titleColor,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
