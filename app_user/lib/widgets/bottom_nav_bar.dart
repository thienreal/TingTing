/// File: bottom_nav_bar.dart
/// Module: SharedWidgets
/// Description: Thanh điều hướng dưới cùng của User App với 4 tab:
///   Trang chủ, Tích điểm, Đổi thưởng, Tài khoản.
///
/// Responsibility:
///   - Cung cấp BottomNavigationBar theo thiết kế TingTing.
///   - Tab active: icon đậm màu đen + text bold màu đen.
///   - Tab inactive: icon outline + text màu xám.
///   - Nền trắng, không có border (elevation nhạt).
///
/// Dependencies:
///   - app_user/lib/core/theme.dart (AppColors)
///
/// Todo:
///   - [ ] Thêm badge số thông báo trên tab "Tích điểm" khi có giao dịch mới
import 'package:flutter/material.dart';
import '../core/theme.dart';

// ==========================================
// ENUM — ĐỊNH NGHĨA CÁC TAB
// ==========================================

/// Enum đại diện cho 4 tab của Bottom Navigation User App.
/// Dùng để tránh hardcode index số nguyên ở các màn hình khác.
enum AppTab {
  home,       // Trang chủ
  earnPoints, // Tích điểm
  rewards,    // Đổi thưởng
  account,    // Tài khoản
}

// ==========================================
// BOTTOM NAV BAR — WIDGET CHÍNH
// ==========================================

/// Thanh điều hướng dưới cùng (Bottom Navigation) của User App.
///
/// Theo UI_Design_Rules §UI Components — Bottom Navigation Bar:
/// - Nền trắng, icon dạng Outline mỏng khi inactive.
/// - Tab Active: icon đậm/filled + text in đậm, màu đen (#1A1A1A).
/// - Tab Inactive: icon outline + text xám (#757575).
///
/// Ví dụ tích hợp vào Scaffold:
/// ```dart
/// Scaffold(
///   body: _buildBody(_currentTab),
///   bottomNavigationBar: AppBottomNavBar(
///     currentTab: _currentTab,
///     onTabChanged: (tab) => setState(() => _currentTab = tab),
///   ),
/// )
/// ```
class AppBottomNavBar extends StatelessWidget {
  final AppTab currentTab;
  final ValueChanged<AppTab> onTabChanged;

  const AppBottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        // Bóng nhạt phía trên thanh nav để tạo độ nổi
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentTab.index,
        onTap: (index) => onTabChanged(AppTab.values[index]),
        type: BottomNavigationBarType.fixed,

        // Màu sắc theo UI_Design_Rules — không hardcode
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.textPrimary,   // Đen đậm khi active
        unselectedItemColor: AppColors.textSecondary, // Xám khi inactive

        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700, // Bold khi active
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 11,
        ),

        // Bỏ shadow mặc định của Flutter, dùng Container bên ngoài
        elevation: 0,

        items: _buildNavItems(),
      ),
    );
  }

  // ==========================================
  // HELPER — TẠO DANH SÁCH NAV ITEMS
  // ==========================================

  /// Xây dựng danh sách 4 [BottomNavigationBarItem].
  /// Active icon dùng Icons filled, inactive dùng Icons outlined
  /// để tạo hiệu ứng "đổi icon" theo UI_Design_Rules.
  List<BottomNavigationBarItem> _buildNavItems() {
    return [
      _buildItem(
        tab: AppTab.home,
        label: 'Trang chủ',
        activeIcon: Icons.home_rounded,
        inactiveIcon: Icons.home_outlined,
      ),
      _buildItem(
        tab: AppTab.earnPoints,
        label: 'Tích điểm',
        activeIcon: Icons.stars_rounded,
        inactiveIcon: Icons.star_outline_rounded,
      ),
      _buildItem(
        tab: AppTab.rewards,
        label: 'Đổi thưởng',
        activeIcon: Icons.card_giftcard_rounded,
        inactiveIcon: Icons.card_giftcard_outlined,
      ),
      _buildItem(
        tab: AppTab.account,
        label: 'Tài khoản',
        activeIcon: Icons.person_rounded,
        inactiveIcon: Icons.person_outline_rounded,
      ),
    ];
  }

  /// Tạo một [BottomNavigationBarItem] với icon active/inactive riêng biệt.
  BottomNavigationBarItem _buildItem({
    required AppTab tab,
    required String label,
    required IconData activeIcon,
    required IconData inactiveIcon,
  }) {
    final isActive = currentTab == tab;
    return BottomNavigationBarItem(
      // Chọn icon filled hoặc outline dựa vào trạng thái active
      icon: Icon(isActive ? activeIcon : inactiveIcon, size: 24),
      activeIcon: Icon(activeIcon, size: 24),
      label: label,
    );
  }
}
