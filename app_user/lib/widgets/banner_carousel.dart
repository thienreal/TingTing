/// File: banner_carousel.dart
/// Module: SharedWidgets
/// Description: Slider trình chiếu các banner chiến dịch nổi bật ở Trang chủ,
///   kèm thanh chấm chỉ báo (dots indicator) theo UI_Design_Rules.
///
/// Responsibility:
///   - Tự động chuyển slide hoặc cho phép vuốt tay ngang
///   - Hiển thị chấm tròn active màu action (#E8687D), inactive màu xám
///
/// Dependencies:
///   - package:flutter/material.dart
///   - app_user/lib/core/theme.dart (AppColors)
///
/// Todo:
///   (File đã hoàn thiện)
library;

import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme.dart';

class BannerItem {
  final String title;
  final String subtitle;
  final String badgeText;
  final List<Color> gradientColors;

  const BannerItem({
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.gradientColors,
  });
}

class BannerCarousel extends StatefulWidget {
  final double height;

  const BannerCarousel({
    super.key,
    this.height = 145,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _autoScrollTimer;

  // Dữ liệu banner mẫu cho MVP
  final List<BannerItem> _banners = const [
    BannerItem(
      title: 'ÚP NGƯỢC SẦU RIÊNG',
      subtitle: 'TĂNG VỌT MOOD CÙNG DAIRY QUEEN',
      badgeText: 'MỚI RA MẮT',
      gradientColors: [Color(0xFFFFF3B0), Color(0xFFCAE7DF)],
    ),
    BannerItem(
      title: 'MỞ TÀI KHOẢN SHB',
      subtitle: 'NHẬN NGAY COMBO 310K + 1200 VUI',
      badgeText: 'HOT DEAL',
      gradientColors: [Color(0xFFFFB37E), Color(0xFFFF8E53)],
    ),
    BannerItem(
      title: 'THE PIZZA COMPANY',
      subtitle: 'GIẢM 100K CHO ĐƠN TỪ 300K',
      badgeText: 'CUỐI TUẦN',
      gradientColors: [Color(0xFFFFD460), Color(0xFFF07B3F)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      int nextIndex = (_currentIndex + 1) % _banners.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: banner.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: AppColors.cardShadow,
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        banner.badgeText,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.action,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      banner.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      banner.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        // ==========================================
        // DOTS INDICATOR
        // ==========================================
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) {
            final isActive = index == _currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? AppColors.action : AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}
