/// File: home_screen.dart
/// Module: HomeFeature
/// Description: Màn hình Trang chủ của User App TingTing.
///   Thiết kế chuẩn theo mẫu anh/643b051b52a0d3fe8ab114.jpg và 9ade81e7d65c57020e4d13.jpg.
///
/// Responsibility:
///   - Hiển thị Header vàng: lời chào người dùng, số dư điểm VUI, chuông thông báo
///   - Thanh tìm kiếm Pill 50px
///   - Thẻ vé nhanh "Ưu đãi của bạn" nếu user đã đổi voucher
///   - Slider banner quảng cáo chiến dịch hot
///   - Danh sách cuộn ngang "Ưu Đãi Mới Cập Bến" và "Deal Hot Ăn Ngon"
///
/// Dependencies:
///   - package:flutter/material.dart
///   - package:flutter_riverpod/flutter_riverpod.dart
///   - package:go_router/go_router.dart
///   - app_user/lib/core/theme.dart (AppColors)
///   - app_user/lib/widgets/voucher_card.dart
///   - app_user/lib/widgets/banner_carousel.dart
///   - app_user/lib/widgets/ticket_notch_clipper.dart
///   - app_user/lib/providers/user_provider.dart
///   - app_user/lib/providers/voucher_provider.dart
///   - app_user/lib/providers/my_voucher_provider.dart
///
/// Todo:
///   (File đã hoàn thiện)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/voucher_card.dart';
import '../../widgets/banner_carousel.dart';
import '../../widgets/ticket_notch_clipper.dart';
import '../../providers/user_provider.dart';
import '../../providers/voucher_provider.dart';
import '../../providers/my_voucher_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final voucherState = ref.watch(voucherProvider);
    final myVoucherState = ref.watch(myVoucherProvider);

    final user = userState.user;
    final totalPoints = user?.totalPoints ?? 0;
    final tier = user?.membershipTier ?? 'STANDARD';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ==========================================
          // TOP HEADER VÀNG & SEARCH BAR
          // ==========================================
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 52, 16, 20),
              child: Column(
                children: [
                  // Row thông tin User & Điểm & Chuông
                  Row(
                    children: [
                      // Avatar linh vật
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('🐤', style: TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Tên và hạng
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName ?? 'Khách hàng TingTing',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Hạng $tier',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Badge điểm VUI
                      InkWell(
                        onTap: () => context.go('/earn'),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text('✦', style: TextStyle(fontSize: 10, color: Colors.white)),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$totalPoints VUI',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Icon chuông thông báo
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Thanh tìm kiếm dạng Pill 50px theo UI_Design_Rules
                  InkWell(
                    onTap: () => context.go('/rewards'),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Row(
                        children: [
                          Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 22),
                          SizedBox(width: 10),
                          Text(
                            'Tìm ưu đãi, thương hiệu...',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ==========================================
          // VÉ NHANH: "ƯU ĐÃI CỦA BẠN" (NẾU CÓ VOUCHER)
          // ==========================================
          if (myVoucherState.activeVouchers.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ưu đãi của bạn [${myVoucherState.activeVouchers.length}]',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        InkWell(
                          onTap: () => context.push('/my-vouchers'),
                          child: const Text(
                            'Tất cả',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.action,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Thẻ vé nhanh đầu tiên
                    Builder(
                      builder: (context) {
                        final voucher = myVoucherState.activeVouchers.first;
                        return InkWell(
                          onTap: () => context.push('/my-voucher/${voucher.id}'),
                          child: TicketContainer(
                            notchRadius: 8,
                            notchPosition: 0.5,
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: SizedBox(
                                      width: 48,
                                      height: 48,
                                      child: voucher.voucher != null
                                          ? Image.network(
                                              voucher.voucher!.realImageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                color: AppColors.primaryLight,
                                                child: const Icon(Icons.confirmation_number_outlined, color: AppColors.action),
                                              ),
                                            )
                                          : Container(
                                              color: AppColors.primaryLight,
                                              child: const Icon(Icons.confirmation_number_outlined, color: AppColors.action),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          voucher.voucher?.merchantName ?? 'Cửa hàng đối tác',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          voucher.voucher?.title ?? 'Voucher ưu đãi',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.actionLight,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Text(
                                      'Dùng ngay',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.action,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

          // ==========================================
          // BANNER CAROUSEL
          // ==========================================
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 20),
              child: BannerCarousel(),
            ),
          ),

          // ==========================================
          // DANH MỤC: ƯU ĐÃI MỚI CẬP BẾN
          // ==========================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ưu Đãi Mới Cập Bến',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  InkWell(
                    onTap: () => context.go('/rewards'),
                    child: const Text(
                      'Tất cả',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.action,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 215,
              child: voucherState.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: voucherState.newVouchers.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final voucher = voucherState.newVouchers[index];
                        return VoucherCard.fromModel(
                          voucher,
                          onTap: () => context.push('/voucher/${voucher.id}'),
                        );
                      },
                    ),
            ),
          ),

          // ==========================================
          // DANH MỤC: DEAL HOT ĂN NGON
          // ==========================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Deal Hot Ăn Ngon',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  InkWell(
                    onTap: () => context.go('/rewards'),
                    child: const Text(
                      'Tất cả',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.action,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 215,
              child: voucherState.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: voucherState.foodDeals.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final voucher = voucherState.foodDeals[index];
                        return VoucherCard.fromModel(
                          voucher,
                          onTap: () => context.push('/voucher/${voucher.id}'),
                        );
                      },
                    ),
            ),
          ),

          // ==========================================
          // KHỐI "CÁCH TÍCH VUI"
          // ==========================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cách Tích VUI Dễ Dàng',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildHowToCard(
                          context,
                          icon: Icons.qr_code_rounded,
                          title: 'Tại quầy',
                          desc: 'Đưa mã QR cho thu ngân quét',
                          onTap: () => context.go('/earn'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildHowToCard(
                          context,
                          icon: Icons.receipt_long_rounded,
                          title: 'Đổi quà',
                          desc: 'Dùng điểm tích lấy voucher',
                          onTap: () => context.go('/rewards'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String desc,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.textPrimary, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
