/// File: transaction_history_screen.dart
/// Module: AccountFeature
/// Description: Màn hình Lịch sử Giao dịch (Tích điểm / Đổi voucher) của User App.
///
/// Responsibility:
///   - Hiển thị danh sách biến động điểm từ GET /users/me/transactions
///   - Phân biệt trực quan giữa giao dịch cộng điểm (EARN, xanh lá) và trừ điểm (REDEEM, đỏ/hồng)
///
/// Dependencies:
///   - package:flutter/material.dart
///   - package:flutter_riverpod/flutter_riverpod.dart
///   - package:go_router/go_router.dart
///   - app_user/lib/core/theme.dart (AppColors)
///   - app_user/lib/providers/user_provider.dart
///
/// Todo:
///   (File đã hoàn thiện)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../providers/user_provider.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final transactions = userState.transactions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lịch sử tích - đổi'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: userState.isTransactionsLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : transactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_toggle_off_rounded, size: 60, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'Chưa có giao dịch tích hoặc đổi điểm nào',
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => ref.read(userProvider.notifier).loadTransactions(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: transactions.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = transactions[index];
                      final isEarn = item.isEarn;
                      final date = item.createdAt;
                      final dateStr = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Row(
                          children: [
                            // Icon trạng thái giao dịch
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isEarn ? AppColors.successLight : AppColors.actionLight,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  isEarn ? Icons.add_rounded : Icons.remove_rounded,
                                  color: isEarn ? AppColors.success : AppColors.action,
                                  size: 26,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Thông tin giao dịch
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isEarn ? item.merchantName : 'Đổi Voucher ưu đãi',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    isEarn && item.billAmount != null
                                        ? 'Hóa đơn: ${item.billAmount!.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ · $dateStr'
                                        : dateStr,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Biến động điểm (+/- X VUI)
                            Text(
                              isEarn ? '+${item.pointsDelta} VUI' : '-${item.pointsDelta} VUI',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isEarn ? AppColors.success : AppColors.action,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
