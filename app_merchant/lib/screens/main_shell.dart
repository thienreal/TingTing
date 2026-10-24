/// File: main_shell.dart
/// Module: Screens
/// Description: Shell điều hướng 4 Tab chính của Merchant App (Tổng quan, Quét mã, Deals, Tài khoản).
///
/// Responsibility:
///   - Cung cấp BottomNavigationBar cố định với 4 tab
///   - Quản lý chuyển tab thông qua StatefulNavigationShell của GoRouter
///   - Đảm bảo tuân thủ UI_Design_Rules về kích thước, đổ bóng và màu sắc
///
/// Dependencies:
///   - package:flutter/material.dart
///   - package:go_router/go_router.dart
///   - app_merchant/lib/core/theme.dart
///
/// Todo:
///   - [ ] Bổ sung badge số lượng voucher sắp hết hạn trên tab Deals
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          boxShadow: AppColors.bottomNavShadow,
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  currentIndex: currentIndex,
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard_rounded,
                  label: 'Tổng quan',
                ),
                _buildNavItem(
                  index: 1,
                  currentIndex: currentIndex,
                  icon: Icons.qr_code_scanner_outlined,
                  activeIcon: Icons.qr_code_scanner_rounded,
                  label: 'Quét mã',
                  isProminent: true,
                ),
                _buildNavItem(
                  index: 2,
                  currentIndex: currentIndex,
                  icon: Icons.local_offer_outlined,
                  activeIcon: Icons.local_offer_rounded,
                  label: 'Quản lý Deal',
                ),
                _buildNavItem(
                  index: 3,
                  currentIndex: currentIndex,
                  icon: Icons.storefront_outlined,
                  activeIcon: Icons.storefront_rounded,
                  label: 'Quầy & Cài đặt',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required int currentIndex,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    bool isProminent = false,
  }) {
    final isSelected = index == currentIndex;

    if (isProminent) {
      return InkWell(
        onTap: () => _onTap(index),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected ? AppColors.cardShadow : null,
                ),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  size: 22,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => _onTap(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: isSelected ? AppColors.action : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.action : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
