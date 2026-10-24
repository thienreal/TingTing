/// File: merchant_vouchers_screen.dart
/// Module: Screens/Vouchers
/// Description: Màn hình Quản lý Danh sách Deal Ưu Đãi do chính Cửa hàng phát hành.
///
/// Responsibility:
///   - Hiển thị danh sách Voucher của quán kèm thanh tiến trình tồn kho
///   - Bộ lọc theo trạng thái: Tất cả, Đang mở đổi, Đã hết / Hết hạn
///   - Nút dẫn sang màn hình Tạo Deal mới (+ Tạo ưu đãi)
///   - Kéo để làm mới dữ liệu
///
/// Dependencies:
///   - package:flutter_riverpod/flutter_riverpod.dart
///   - package:go_router/go_router.dart
///   - app_merchant/lib/core/theme.dart
///   - app_merchant/lib/models/merchant_voucher_model.dart
///   - app_merchant/lib/providers/merchant_voucher_provider.dart
///
/// Todo:
///   - [ ] Bổ sung tính năng chỉnh sửa số lượng voucher đang chạy
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../models/merchant_voucher_model.dart';
import '../../providers/merchant_voucher_provider.dart';

enum VoucherFilter { all, active, crossMerchant, inactive }

class MerchantVouchersScreen extends ConsumerStatefulWidget {
  const MerchantVouchersScreen({super.key});

  @override
  ConsumerState<MerchantVouchersScreen> createState() => _MerchantVouchersScreenState();
}

class _MerchantVouchersScreenState extends ConsumerState<MerchantVouchersScreen> {
  VoucherFilter _currentFilter = VoucherFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(merchantVoucherProvider.notifier).fetchVouchers();
    });
  }

  List<MerchantVoucher> _filterVouchers(List<MerchantVoucher> list) {
    switch (_currentFilter) {
      case VoucherFilter.all:
        return list;
      case VoucherFilter.active:
        return list.where((v) => v.isActive).toList();
      case VoucherFilter.crossMerchant:
        return list.where((v) => v.isCrossMerchant).toList();
      case VoucherFilter.inactive:
        return list.where((v) => !v.isActive).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final voucherState = ref.watch(merchantVoucherProvider);
    final displayedList = _filterVouchers(voucherState.vouchers);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quản Lý Ưu Đãi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(merchantVoucherProvider.notifier).fetchVouchers(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        elevation: 3,
        icon: const Icon(Icons.add_rounded, fontWeight: FontWeight.w800),
        label: const Text('Tạo Deal mới', style: TextStyle(fontWeight: FontWeight.w700)),
        onPressed: () => context.push('/vouchers/create'),
      ),
      body: RefreshIndicator(
        color: AppColors.action,
        onRefresh: () => ref.read(merchantVoucherProvider.notifier).fetchVouchers(),
        child: Column(
          children: [
            // ==========================================
            // BỘ LỌC TRẠNG THÁI (CHIPS)
            // ==========================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: AppColors.card,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Tất cả (${voucherState.vouchers.length})', VoucherFilter.all),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Đang mở đổi (${voucherState.vouchers.where((v) => v.isActive).length})',
                      VoucherFilter.active,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      '🤝 Deal liên kết (${voucherState.vouchers.where((v) => v.isCrossMerchant).length})',
                      VoucherFilter.crossMerchant,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip('Đã hết', VoucherFilter.inactive),
                  ],
                ),
              ),
            ),

            // ==========================================
            // DANH SÁCH VOUCHER
            // ==========================================
            Expanded(
              child: voucherState.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.action))
                  : displayedList.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
                          itemCount: displayedList.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _buildVoucherCard(displayedList[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, VoucherFilter filter) {
    final isSelected = _currentFilter == filter;
    return InkWell(
      onTap: () => setState(() => _currentFilter = filter),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.action : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildVoucherCard(MerchantVoucher voucher) {
    final percentRemaining = voucher.totalQuantity > 0
        ? (voucher.remainingQuantity / voucher.totalQuantity).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (voucher.isCrossMerchant) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.actionLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.handshake_rounded, size: 13, color: AppColors.action),
                  const SizedBox(width: 5),
                  Text(
                    '🤝 LIÊN KẾT: Áp dụng tại ${voucher.targetMerchantName ?? "Đối tác TingTing"}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.action,
                    ),
                  ),
                ],
              ),
            ),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: voucher.isCrossMerchant ? AppColors.actionLight : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    voucher.isCrossMerchant ? Icons.stars_rounded : Icons.card_giftcard_rounded,
                    color: voucher.isCrossMerchant ? AppColors.action : AppColors.primaryDark,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      voucher.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (voucher.description != null && voucher.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        voucher.description!,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(voucher),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),

          // Thông số Điểm & Tồn kho
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.monetization_on_rounded, size: 16, color: AppColors.primaryDark),
                  const SizedBox(width: 4),
                  Text(
                    '${voucher.pointsCost} VUI',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                'Tồn kho: ${voucher.remainingQuantity}/${voucher.totalQuantity}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Thanh tiến trình tồn kho
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentRemaining,
              minHeight: 6,
              backgroundColor: AppColors.inputBackground,
              valueColor: AlwaysStoppedAnimation<Color>(
                voucher.isActive ? AppColors.primaryDark : AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Hạn sử dụng
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.event_outlined, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    'HSD: ${_formatDate(voucher.expiredAt)}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
              if (voucher.isExpired)
                const Text(
                  'Đã hết hạn',
                  style: TextStyle(fontSize: 11, color: AppColors.action, fontWeight: FontWeight.w600),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(MerchantVoucher voucher) {
    if (voucher.isExpired) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.actionLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Hết hạn',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.action),
        ),
      );
    }
    if (voucher.isOutOfStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Hết lượt',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Đang mở',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_offer_outlined, size: 56, color: AppColors.textMuted),
            const SizedBox(height: 16),
            const Text(
              'Chưa có ưu đãi nào',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tạo ưu đãi mới để thu hút khách hàng tích điểm và đổi voucher tại quán của bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Tạo Deal đầu tiên', style: TextStyle(fontWeight: FontWeight.w700)),
              onPressed: () => context.push('/vouchers/create'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d/$m/${dt.year}';
  }
}
