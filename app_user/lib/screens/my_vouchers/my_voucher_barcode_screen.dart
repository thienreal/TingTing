/// File: my_voucher_barcode_screen.dart
/// Module: MyVouchersFeature
/// Description: Màn hình hiển thị mã Barcode/QR của voucher để thu ngân quét áp dụng.
///   Thiết kế chuẩn theo mẫu anh/2dc80bab5c10dd4e840128.jpg.
///
/// Responsibility:
///   - Hiển thị mã vạch vector 1D sắc nét của mã voucher cá nhân (UserVoucher ID)
///   - Cung cấp nút sao chép mã và thông tin hướng dẫn sử dụng tại quầy
///   - Hỗ trợ xem mã QR phụ
///
/// Dependencies:
///   - package:flutter/material.dart
///   - package:flutter_riverpod/flutter_riverpod.dart
///   - package:go_router/go_router.dart
///   - app_user/lib/core/theme.dart (AppColors)
///   - app_user/lib/widgets/ticket_notch_clipper.dart
///   - app_user/lib/widgets/barcode_widget.dart
///   - app_user/lib/models/user_voucher_model.dart
///   - app_user/lib/providers/my_voucher_provider.dart
///
/// Todo:
///   (File đã hoàn thiện)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme.dart';
import '../../widgets/ticket_notch_clipper.dart';
import '../../widgets/barcode_widget.dart';
import '../../models/user_voucher_model.dart';
import '../../providers/my_voucher_provider.dart';

class MyVoucherBarcodeScreen extends ConsumerWidget {
  final String userVoucherId;

  const MyVoucherBarcodeScreen({
    super.key,
    required this.userVoucherId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myVouchers = ref.watch(myVoucherProvider).vouchers;
    UserVoucherModel? item;
    try {
      item = myVouchers.firstWhere((v) => v.id == userVoucherId);
    } catch (_) {
      item = null;
    }

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mã voucher')),
        body: const Center(child: Text('Không tìm thấy thông tin voucher')),
      );
    }

    final voucher = item.voucher;
    final merchantName = voucher?.merchantName ?? 'TingTing Partner';
    final isCross = voucher?.isCrossMerchant ?? false;
    final targetMerchantName = voucher?.targetMerchantName ?? merchantName;
    final title = voucher?.title ?? 'Voucher ưu đãi';
    // Mã ngắn gọn cho thu ngân nhập nếu máy quét lỗi
    final displayCode = item.id.length >= 8 ? item.id.substring(0, 8).toUpperCase() : item.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mã voucher'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ==========================================
            // THẺ VÉ TICKET NOTCH CHỨA MÃ VẠCH (BARCODE)
            // ==========================================
            TicketContainer(
              notchRadius: 14,
              notchPosition: 0.72,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  children: [
                    if (isCross) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.actionLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '🤝 Ưu đãi liên kết: Tài trợ bởi $merchantName',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.action,
                          ),
                        ),
                      ),
                    ],
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Còn 1/1 lượt dùng · HSD: ${voucher?.expiredAt.day}/${voucher?.expiredAt.month}/${voucher?.expiredAt.year}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Mã vạch vector
                    BarcodeDisplayWidget(
                      code: displayCode,
                      copyValue: item.id,
                      height: 80,
                    ),
                    const SizedBox(height: 16),

                    // Mã QR hỗ trợ máy quét camera tại quầy
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border.withOpacity(0.5)),
                      ),
                      child: Column(
                        children: [
                          QrImageView(
                            data: 'tingting:voucher:${item.id}',
                            version: QrVersions.auto,
                            size: 140,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: AppColors.textPrimary,
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Hoặc quét mã QR này tại quầy',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Đường nét đứt ngang
                    CustomPaint(
                      size: const Size(double.infinity, 1),
                      painter: DashedLinePainter(),
                    ),
                    const SizedBox(height: 18),

                    // Thông tin thương hiệu
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(Icons.storefront_rounded, size: 20, color: AppColors.textPrimary),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isCross ? 'ÁP DỤNG: ${targetMerchantName.toUpperCase()}' : merchantName.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (isCross)
                                Text(
                                  'Tài trợ: $merchantName',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.actionLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isCross ? 'Liên minh' : 'Sẵn sàng dùng',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.action,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ==========================================
            // HƯỚNG DẪN THU NGÂN QUÉT MÃ
            // ==========================================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.action, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isCross
                          ? 'Đưa mã barcode này cho nhân viên thu ngân tại $targetMerchantName để được áp dụng ưu đãi trực tiếp vào hóa đơn thanh toán.'
                          : 'Đưa mã barcode này cho nhân viên thu ngân quét để được áp dụng ưu đãi trực tiếp vào hóa đơn thanh toán.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
