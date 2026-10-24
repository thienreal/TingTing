/// File: main_shell.dart
/// Module: Navigation
/// Description: Khung giao diện chính (Shell) của User App chứa 4 Tabs
///   và BottomNavigationBar, sử dụng StatefulNavigationShell của GoRouter.
///
/// Responsibility:
///   - Duy trì trạng thái (KeepAlive) của các tab khi chuyển đổi
///   - Đồng bộ index giữa GoRouter và AppBottomNavBar
///
/// Dependencies:
///   - package:flutter/material.dart
///   - package:go_router/go_router.dart
///   - app_user/lib/widgets/bottom_nav_bar.dart
///
/// Todo:
///   (File đã hoàn thiện)
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bottom_nav_bar.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;
    final currentTab = (currentIndex >= 0 && currentIndex < AppTab.values.length)
        ? AppTab.values[currentIndex]
        : AppTab.home;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        currentTab: currentTab,
        onTabChanged: (tab) {
          navigationShell.goBranch(
            tab.index,
            initialLocation: tab.index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
