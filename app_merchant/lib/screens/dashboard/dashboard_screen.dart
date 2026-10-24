/// File: dashboard_screen.dart
/// Module: Screens/Dashboard
/// Description: Màn hình Tổng quan kinh doanh của Cửa hàng đối tác.
///
/// Responsibility:
///   - Hiển thị 4 thẻ KPI: Voucher đang phát hành, Tổng điểm đã cấp, Tổng giao dịch, Voucher đã dùng
///   - Các nút tác vụ nhanh (Tích điểm, Trừ voucher, Tạo deal mới)
///   - Danh sách 10 giao dịch gần nhất kèm trạng thái và thời gian chi tiết
///   - Hỗ trợ kéo để làm mới (Pull-to-refresh)
///
/// Dependencies:
///   - package:flutter_riverpod/flutter_riverpod.dart
///   - package:go_router/go_router.dart
///   - app_merchant/lib/core/theme.dart
///   - app_merchant/lib/providers/merchant_auth_provider.dart
///   - app_merchant/lib/providers/report_provider.dart
///   - app_merchant/lib/widgets/transaction_tile.dart
///
/// Todo:
///   - [ ] Bổ sung bộ lọc giao dịch theo ngày/tháng
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../providers/merchant_auth_provider.dart';
import '../../providers/report_provider.dart';
import '../../widgets/transaction_tile.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Tải dữ liệu dashboard ngay khi mở màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reportProvider.notifier).fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(merchantAuthProvider);
    final reportState = ref.watch(reportProvider);
    final merchant = authState.merchant;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 20,
        backgroundColor: AppColors.card,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(Icons.storefront_rounded, color: AppColors.primaryDark, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    merchant?.name ?? 'Cửa hàng đối tác',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${merchant?.category ?? "Đối tác"} • TingTing Portal',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(radius: 3, backgroundColor: AppColors.success),
                  SizedBox(width: 4),
                  Text(
                    'Đang hoạt động',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.action,
        onRefresh: () => ref.read(reportProvider.notifier).fetchDashboardData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // KHỐI 4 THẺ CHỈ SỐ KPI
              // ==========================================
              Row(
                children: [
                  Expanded(
                    child: _buildKpiCard(
                      title: 'Voucher đang chạy',
                      value: '${reportState.report.activeVouchersCount}',
                      icon: Icons.confirmation_number_outlined,
                      color: const Color(0xFF3498DB),
                      bgColor: const Color(0xFFEBF5FB),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildKpiCard(
                      title: 'Điểm đã phát hành',
                      value: _formatNumber(reportState.report.totalPointsIssued),
                      unit: 'VUI',
                      icon: Icons.monetization_on_outlined,
                      color: const Color(0xFFF39C12),
                      bgColor: const Color(0xFFFEF9E7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildKpiCard(
                      title: 'Tổng giao dịch',
                      value: '${reportState.report.totalTransactions}',
                      icon: Icons.receipt_long_outlined,
                      color: const Color(0xFF2ECC71),
                      bgColor: const Color(0xFFEAFAF1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildKpiCard(
                      title: 'Voucher đã dùng',
                      value: '${reportState.report.usedVouchersCount}',
                      icon: Icons.task_alt_outlined,
                      color: AppColors.action,
                      bgColor: AppColors.actionLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ==========================================
              // KHỐI TÁC VỤ NHANH
              // ==========================================
              const Text(
                'Tác vụ thu ngân nhanh',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      label: 'Tích điểm',
                      sublabel: 'Quét QR khách',
                      icon: Icons.qr_code_scanner_rounded,
                      color: AppColors.primary,
                      textColor: AppColors.textPrimary,
                      onTap: () => context.go('/scan'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      label: 'Trừ voucher',
                      sublabel: 'Quét mã ưu đãi',
                      icon: Icons.card_giftcard_rounded,
                      color: AppColors.card,
                      textColor: AppColors.action,
                      borderColor: AppColors.action.withValues(alpha: 0.3),
                      onTap: () => context.go('/scan'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      label: '+ Tạo Deal',
                      sublabel: 'Ưu đãi mới',
                      icon: Icons.add_circle_outline_rounded,
                      color: AppColors.card,
                      textColor: AppColors.textPrimary,
                      borderColor: AppColors.border,
                      onTap: () => context.push('/vouchers/create'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ==========================================
              // DANH SÁCH GIAO DỊCH GẦN NHẤT
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lịch sử giao dịch gần đây',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${reportState.recentTransactions.length} giao dịch',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (reportState.isLoading) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.action),
                  ),
                ),
              ] else if (reportState.recentTransactions.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: const Center(
                    child: Column(
                      children: [
                        Icon(Icons.inbox_outlined, size: 48, color: AppColors.textMuted),
                        SizedBox(height: 12),
                        Text(
                          'Chưa có giao dịch nào được ghi nhận',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Các lần tích điểm và dùng voucher sẽ xuất hiện ở đây',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                ...reportState.recentTransactions.map((tx) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TransactionTile(
                      data: TransactionTileData(
                        type: tx.isEarn
                            ? TransactionType.earnPoints
                            : TransactionType.useVoucher,
                        subject: '${tx.userName} (${tx.userPhone})',
                        pointsDelta: tx.pointsDelta,
                        billAmount: tx.billAmount,
                        createdAt: tx.createdAt,
                      ),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET BUILDERS
  // ==========================================

  Widget _buildKpiCard({
    required String title,
    required String value,
    String? unit,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (unit != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required String sublabel,
    required IconData icon,
    required Color color,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: borderColor != null ? Border.all(color: borderColor) : null,
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: textColor),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              sublabel,
              style: TextStyle(
                fontSize: 10,
                color: textColor.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
