/// File: merchant_account_screen.dart
/// Module: Screens/Account
/// Description: Màn hình Quầy & Tài khoản Cửa hàng: Thông tin quán, QR quầy tĩnh, Đổi tài khoản demo & Đăng xuất.
///
/// Responsibility:
///   - Hiển thị thông tin đối tác và mã QR tĩnh tại quầy (qr_static_code) bằng QrImageView
///   - Hỗ trợ đổi nhanh sang tài khoản thương hiệu khác để kiểm thử
///   - Đăng xuất an toàn khỏi ứng dụng
///
/// Dependencies:
///   - package:qr_flutter/qr_flutter.dart
///   - package:flutter_riverpod/flutter_riverpod.dart
///   - app_merchant/lib/core/theme.dart
///   - app_merchant/lib/providers/merchant_auth_provider.dart
///   - app_merchant/lib/widgets/action_button.dart
///
/// Todo:
///   - [ ] Bổ sung tải file PDF mã QR tĩnh kích thước A6/A5 để in ấn
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme.dart';
import '../../providers/merchant_auth_provider.dart';
import '../../widgets/action_button.dart';

class MerchantAccountScreen extends ConsumerWidget {
  const MerchantAccountScreen({super.key});

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Đăng xuất tài khoản?', style: TextStyle(fontWeight: FontWeight.w700)),
          content: const Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi cổng quản trị cửa hàng?',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.action,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(merchantAuthProvider.notifier).logout();
              },
              child: const Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(merchantAuthProvider);
    final merchant = authState.merchant;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quầy & Cài Đặt'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==========================================
            // THẺ HỒ SƠ CỬA HÀNG
            // ==========================================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(Icons.storefront_rounded, size: 32, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          merchant?.name ?? 'Cửa hàng đối tác',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          merchant?.email ?? '',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.actionLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Ngành hàng: ${merchant?.category ?? "Đối tác"}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.action,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ==========================================
            // MÃ QR TĨNH ĐẶT TẠI QUẦY (qr_static_code)
            // ==========================================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.qr_code_2_rounded, color: AppColors.primaryDark),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mã QR Tĩnh Tại Quầy',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Dành cho khách hàng quét tại thu ngân',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Mã QR
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: QrImageView(
                      data: merchant?.qrStaticCode ?? 'QR_MERCHANT',
                      version: QrVersions.auto,
                      size: 180,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Mã chữ in đậm
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'MÃ ĐỐI TÁC: ${merchant?.qrStaticCode ?? ""}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'In mã này đặt tại quầy thu ngân hoặc trên standee để khách hàng nhận diện cửa hàng trong hệ thống TingTing.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ==========================================
            // CHUYỂN NHANH ĐỐI TÁC KHÁC (DEMO TEST)
            // ==========================================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đổi thương hiệu kiểm thử nhanh',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: demoMerchantAccounts.map((acc) {
                      final isCurrent = acc.email == merchant?.email;
                      return ChoiceChip(
                        label: Text(acc.name),
                        selected: isCurrent,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.inputBackground,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                          color: isCurrent ? AppColors.textPrimary : AppColors.textSecondary,
                        ),
                        onSelected: (selected) {
                          if (selected && !isCurrent) {
                            ref.read(merchantAuthProvider.notifier).login(acc.email, acc.password);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ==========================================
            // NÚT ĐĂNG XUẤT
            // ==========================================
            ActionButton(
              label: 'Đăng xuất cửa hàng',
              icon: Icons.logout_rounded,
              variant: ActionButtonVariant.outlined,
              onPressed: () => _confirmLogout(context, ref),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'TingTing Merchant v1.0.0 (Production-Ready MVP)',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
