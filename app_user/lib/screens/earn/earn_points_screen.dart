/// File: earn_points_screen.dart
/// Module: EarnFeature
/// Description: Màn hình Tích điểm của User App TingTing.
///   Thiết kế chuẩn theo mẫu anh/2c24dd738ac80b9652d918.jpg.
///
/// Responsibility:
///   - Hiển thị Dynamic QR Code định danh của user, làm mới mỗi 60 giây
///   - Hiển thị số dư điểm và mã thành viên
///   - Cung cấp danh sách các Thương hiệu đối tác tích điểm
///
/// Dependencies:
///   - package:flutter/material.dart
///   - package:flutter_riverpod/flutter_riverpod.dart
///   - app_user/lib/core/theme.dart (AppColors)
///   - app_user/lib/widgets/dynamic_qr_view.dart
///   - app_user/lib/providers/user_provider.dart
///
/// Todo:
///   (File đã hoàn thiện)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../widgets/dynamic_qr_view.dart';
import '../../providers/user_provider.dart';

class EarnPointsScreen extends ConsumerWidget {
  const EarnPointsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final user = userState.user;

    final userId = user?.id ?? 'guest-user-id';
    final totalPoints = user?.totalPoints ?? 0;
    final phoneNumber = user?.phoneNumber ?? '---';
    final tier = user?.membershipTier ?? 'STANDARD';

    // Danh sách đối tác nổi bật cho MVP
    final partners = const [
      {'name': 'The Pizza Company', 'category': 'F&B', 'deals': '1 ưu đãi'},
      {'name': 'Chang Modern Thai', 'category': 'F&B', 'deals': '3 ưu đãi'},
      {'name': 'Dairy Queen', 'category': 'Tráng miệng', 'deals': '2 ưu đãi'},
      {'name': 'KFC Việt Nam', 'category': 'Thức ăn nhanh', 'deals': '8 ưu đãi'},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tích điểm'),
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==========================================
            // THẺ THÔNG TIN ĐIỂM & HỘI VIÊN
            // ==========================================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
              ),
              child: Row(
                children: [
                  // Cột điểm khả dụng
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Điểm khả dụng',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
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
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Đường phân cách dọc
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.border,
                  ),

                  // Cột mã thành viên
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mã thành viên',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            phoneNumber,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Hạng $tier',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.action,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ==========================================
            // KHỐI DYNAMIC QR CODE (LÀM MỚI MỖI 60s)
            // ==========================================
            DynamicQrView(userId: userId),
            const SizedBox(height: 24),

            // ==========================================
            // THƯƠNG HIỆU TÍCH ĐIỂM ĐỐI TÁC
            // ==========================================
            const Text(
              'Thương hiệu tích điểm',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              itemCount: partners.length,
              itemBuilder: (context, index) {
                final partner = partners[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(Icons.storefront_rounded, color: AppColors.textPrimary, size: 22),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        partner['name']!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${partner['category']} · ${partner['deals']}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
