/// File: rewards_screen.dart
/// Module: RewardsFeature
/// Description: Màn hình Đổi thưởng (Marketplace) của User App TingTing.
///   Thiết kế chuẩn theo mẫu anh/9955dd1d8aa60bf852b722.jpg và 528076dd2166a038f97720.jpg.
///
/// Responsibility:
///   - Thanh tìm kiếm ưu đãi bo tròn 50px dạng Pill
///   - Bộ lọc danh mục (Tất cả, Ẩm thực, Mua sắm, Giải trí)
///   - Lưới danh sách thẻ VoucherCard sắc nét, click xem chi tiết
///
/// Dependencies:
///   - package:flutter/material.dart
///   - package:flutter_riverpod/flutter_riverpod.dart
///   - package:go_router/go_router.dart
///   - app_user/lib/core/theme.dart (AppColors)
///   - app_user/lib/widgets/voucher_card.dart
///   - app_user/lib/providers/voucher_provider.dart
///
/// Todo:
///   (File đã hoàn thiện)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/voucher_card.dart';
import '../../providers/voucher_provider.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _categories = const [
    {'title': 'Tất cả', 'icon': Icons.apps_rounded},
    {'title': 'Ẩm thực', 'icon': Icons.fastfood_rounded},
    {'title': 'Mua sắm', 'icon': Icons.shopping_bag_rounded},
    {'title': 'Giải trí', 'icon': Icons.movie_rounded},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(voucherProvider.notifier).loadVouchers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voucherState = ref.watch(voucherProvider);
    final vouchers = voucherState.filteredVouchers;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Đổi thưởng'),
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // ==========================================
          // HEADER VÀNG & SEARCH PILL BAR
          // ==========================================
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        ref.read(voucherProvider.notifier).setSearchQuery(val);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Tìm ưu đãi, thương hiệu, món ăn...',
                        hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textSecondary),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(voucherProvider.notifier).setSearchQuery('');
                      },
                    ),
                ],
              ),
            ),
          ),

          // ==========================================
          // DANH MỤC THỂ LOẠI (CHIPS)
          // ==========================================
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              height: 38,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = voucherState.selectedCategory == cat['title'];

                  return InkWell(
                    onTap: () {
                      ref.read(voucherProvider.notifier).setCategory(cat['title'] as String);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.action : AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            cat['icon'] as IconData,
                            size: 16,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cat['title'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ==========================================
          // LƯỚI DANH SÁCH VOUCHER
          // ==========================================
          Expanded(
            child: voucherState.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : vouchers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 54, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text(
                              'Không tìm thấy ưu đãi phù hợp',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () => ref.read(voucherProvider.notifier).loadVouchers(),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.76,
                          ),
                          itemCount: vouchers.length,
                          itemBuilder: (context, index) {
                            final voucher = vouchers[index];
                            return VoucherCard.fromModel(
                              voucher,
                              width: double.infinity,
                              onTap: () => context.push('/voucher/${voucher.id}'),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
