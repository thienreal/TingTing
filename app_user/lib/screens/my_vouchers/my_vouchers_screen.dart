/// File: my_vouchers_screen.dart
/// Module: MyVouchersFeature
/// Description: Màn hình Danh sách Ưu đãi của bạn (My Vouchers).
///   Thiết kế chuẩn theo mẫu anh/1e1f616536deb780eecf27.jpg với 3 Tabs
///   và gạch chân màu hồng/đỏ san hô #E8687D theo UI_Design_Rules.
///
/// Responsibility:
///   - Quản lý 3 tabs: "Đang có [count]", "Đã dùng", "Hết hạn"
///   - Hiển thị danh sách vé voucher dạng Ticket Notch bo tròn
///   - Điều hướng sang MyVoucherBarcodeScreen khi bấm vào vé
///
/// Dependencies:
///   - package:flutter/material.dart
///   - package:flutter_riverpod/flutter_riverpod.dart
///   - package:go_router/go_router.dart
///   - app_user/lib/core/theme.dart (AppColors)
///   - app_user/lib/widgets/ticket_notch_clipper.dart
///   - app_user/lib/providers/my_voucher_provider.dart
///
/// Todo:
///   (File đã hoàn thiện)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/ticket_notch_clipper.dart';
import '../../models/user_voucher_model.dart';
import '../../providers/my_voucher_provider.dart';

class MyVouchersScreen extends ConsumerStatefulWidget {
  const MyVouchersScreen({super.key});

  @override
  ConsumerState<MyVouchersScreen> createState() => _MyVouchersScreenState();
}

class _MyVouchersScreenState extends ConsumerState<MyVouchersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myVoucherProvider.notifier).loadMyVouchers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myVoucherState = ref.watch(myVoucherProvider);
    final activeCount = myVoucherState.activeVouchers.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ưu đãi của bạn'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          // Tab active gạch chân màu hồng theo UI_Design_Rules §Tabs
          indicatorColor: AppColors.action,
          indicatorWeight: 3.0,
          labelColor: AppColors.textPrimary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          unselectedLabelColor: AppColors.textSecondary,
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          tabs: [
            Tab(text: 'Đang có [$activeCount]'),
            const Tab(text: 'Đã dùng'),
            const Tab(text: 'Hết hạn'),
          ],
        ),
      ),
      body: myVoucherState.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildVoucherList(myVoucherState.activeVouchers, emptyMessage: 'Bạn chưa có ưu đãi nào'),
                _buildVoucherList(myVoucherState.usedVouchers, emptyMessage: 'Chưa có ưu đãi nào đã sử dụng'),
                _buildVoucherList(myVoucherState.expiredVouchers, emptyMessage: 'Không có ưu đãi nào hết hạn'),
              ],
            ),
    );
  }

  Widget _buildVoucherList(List<UserVoucherModel> list, {required String emptyMessage}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.confirmation_number_outlined, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              emptyMessage,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(myVoucherProvider.notifier).loadMyVouchers(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = list[index];
          final voucher = item.voucher;
          final isUsed = item.isUsed;
          final isExpired = item.isExpired;

          return InkWell(
            onTap: isUsed || isExpired ? null : () => context.push('/my-voucher/${item.id}'),
            child: TicketContainer(
              notchRadius: 10,
              notchPosition: 0.5,
              backgroundColor: isUsed || isExpired ? const Color(0xFFF9F9F9) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Thumbnail ảnh thực tế của voucher
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 52,
                        height: 52,
                        child: voucher != null
                            ? Image.network(
                                voucher.realImageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: isUsed || isExpired ? Colors.grey.shade200 : AppColors.primaryLight,
                                  child: Icon(
                                    Icons.local_offer_rounded,
                                    color: isUsed || isExpired ? Colors.grey : AppColors.action,
                                    size: 24,
                                  ),
                                ),
                              )
                            : Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.local_offer_rounded, color: Colors.grey),
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Nội dung thông tin voucher
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            voucher?.merchantName ?? 'Cửa hàng đối tác',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            voucher?.title ?? 'Voucher TingTing',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isUsed || isExpired ? AppColors.textSecondary : AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            voucher != null
                                ? 'Hạn dùng: ${voucher.expiredAt.day}/${voucher.expiredAt.month}/${voucher.expiredAt.year}'
                                : 'HSD: 30 ngày',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Tag trạng thái
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isUsed
                            ? Colors.grey.shade200
                            : (isExpired ? Colors.red.shade50 : AppColors.actionLight),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isUsed ? 'Đã dùng' : (isExpired ? 'Hết hạn' : 'Dùng ngay'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isUsed
                              ? Colors.grey.shade700
                              : (isExpired ? Colors.red : AppColors.action),
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
    );
  }
}
