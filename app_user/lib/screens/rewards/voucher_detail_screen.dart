/// File: voucher_detail_screen.dart
/// Module: RewardsFeature
/// Description: Màn hình Chi tiết Voucher của User App TingTing.
///   Thiết kế chuẩn theo mẫu anh/04f3c69d91261078493729.jpg với Thẻ vé Ticket Notch.
///
/// Responsibility:
///   - Hiển thị ảnh lớn, thẻ vé cắt notch bán nguyệt 2 bên, điều kiện sử dụng
///   - Thanh cố định đáy màn hình hiển thị giá điểm và nút "Đổi ngay"
///   - Gọi API POST /vouchers/:id/redeem và hiển thị dialog đổi thành công
///
/// Dependencies:
///   - package:flutter/material.dart
///   - package:flutter_riverpod/flutter_riverpod.dart
///   - package:go_router/go_router.dart
///   - app_user/lib/core/theme.dart (AppColors)
///   - app_user/lib/widgets/primary_button.dart
///   - app_user/lib/widgets/ticket_notch_clipper.dart
///   - app_user/lib/models/voucher_model.dart
///   - app_user/lib/providers/voucher_provider.dart
///   - app_user/lib/providers/user_provider.dart
///   - app_user/lib/providers/my_voucher_provider.dart
///
/// Todo:
///   (File đã hoàn thiện)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/ticket_notch_clipper.dart';
import '../../models/voucher_model.dart';
import '../../providers/voucher_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/my_voucher_provider.dart';

class VoucherDetailScreen extends ConsumerStatefulWidget {
  final String voucherId;

  const VoucherDetailScreen({
    super.key,
    required this.voucherId,
  });

  @override
  ConsumerState<VoucherDetailScreen> createState() => _VoucherDetailScreenState();
}

class _VoucherDetailScreenState extends ConsumerState<VoucherDetailScreen> {
  VoucherModel? _voucher;

  @override
  void initState() {
    super.initState();
    _findVoucher();
  }

  void _findVoucher() {
    final vouchers = ref.read(voucherProvider).allVouchers;
    try {
      _voucher = vouchers.firstWhere((v) => v.id == widget.voucherId);
    } catch (_) {
      _voucher = null;
    }
  }

  Future<void> _handleRedeem(VoucherModel voucher) async {
    final user = ref.read(userProvider).user;
    final userPoints = user?.totalPoints ?? 0;

    if (userPoints < voucher.pointsCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bạn không đủ điểm để đổi. Cần ${voucher.pointsCost} VUI, bạn đang có $userPoints VUI.'),
          backgroundColor: AppColors.action,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Hiển thị Dialog xác nhận đổi điểm
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận đổi voucher', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Bạn có chắc muốn dùng ${voucher.pointsCost} điểm VUI để đổi voucher "${voucher.title}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.action,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Đổi ngay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final result = await ref.read(myVoucherProvider.notifier).redeemVoucher(voucher.id);

    if (!mounted) return;

    if (result['success'] == true) {
      // Hiển thị Dialog chúc mừng
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 65,
                height: 65,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Text('🎉', style: TextStyle(fontSize: 32))),
              ),
              const SizedBox(height: 16),
              const Text(
                'Đổi Thành Công!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Voucher "${voucher.title}" đã được thêm vào mục "Ưu đãi của bạn".',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Xem ưu đãi của tôi',
                onPressed: () {
                  Navigator.pop(ctx);
                  context.push('/my-vouchers');
                },
              ),
            ],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] as String),
          backgroundColor: AppColors.action,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_voucher == null) {
      _findVoucher();
    }

    final voucher = _voucher;
    if (voucher == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết ưu đãi')),
        body: const Center(child: Text('Không tìm thấy thông tin voucher')),
      );
    }

    final myVoucherState = ref.watch(myVoucherProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ==========================================
              // TOP HERO IMAGE VỚI NÚT QUAY LẠI
              // ==========================================
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    SizedBox(
                      height: 250,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            voucher.realImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.action,
                              child: const Center(
                                child: Icon(Icons.card_giftcard_rounded, size: 64, color: Colors.white),
                              ),
                            ),
                          ),
                          // Lớp gradient mờ tăng tương phản cho icon và tiêu đề
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.4),
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.6),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: const [0.0, 0.4, 1.0],
                              ),
                            ),
                          ),
                          // Badge tên thương hiệu góc dưới ảnh
                          Positioned(
                            bottom: 40,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.65),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                voucher.isCrossMerchant
                                    ? '${voucher.merchantName.toUpperCase()} ➔ ${voucher.targetMerchantName.toUpperCase()}'
                                    : voucher.merchantName.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white.withOpacity(0.9),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
                                onPressed: () => context.pop(),
                              ),
                            ),
                            CircleAvatar(
                              backgroundColor: Colors.white.withOpacity(0.9),
                              child: const Icon(Icons.favorite_border_rounded, size: 20, color: AppColors.action),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ==========================================
              // THẺ TICKET NOTCH (VẾT CẮT BÁN NGUYỆT 2 BÊN)
              // ==========================================
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -30),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TicketContainer(
                      notchRadius: 12,
                      notchPosition: 0.65,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (voucher.isCrossMerchant) ...[
                            Container(
                              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.actionLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.handshake_rounded, size: 16, color: AppColors.action),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'ƯU ĐÃI LIÊN KẾT KÍCH CẦU CHÉO\nTài trợ bởi ${voucher.merchantName} • Áp dụng tại ${voucher.targetMerchantName}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.action,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                            child: Column(
                              children: [
                                Text(
                                  voucher.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Hạn dùng: ${voucher.expiredAt.day}/${voucher.expiredAt.month}/${voucher.expiredAt.year} · Còn lại: ${voucher.remainingQuantity}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Đường nét đứt nối giữa 2 vết cắt
                          CustomPaint(
                            size: const Size(double.infinity, 1),
                            painter: DashedLinePainter(),
                          ),

                          // Phần chân vé: Logo & Thông tin Merchant
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.storefront_rounded, color: AppColors.textPrimary),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        voucher.isCrossMerchant
                                            ? 'ÁP DỤNG: ${voucher.targetMerchantName.toUpperCase()}'
                                            : voucher.merchantName.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      if (voucher.isCrossMerchant) ...[
                                        Text(
                                          'Tài trợ: ${voucher.merchantName}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    voucher.isCrossMerchant ? 'Liên minh' : 'Đối tác TingTing',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF996500),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ==========================================
              // ĐIỀU KIỆN SỬ DỤNG & CÁCH DÙNG
              // ==========================================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner tìm cửa hàng
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF3FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Text('📍', style: TextStyle(fontSize: 26)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Áp dụng tại hệ thống cửa hàng',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                  ),
                                  Text(
                                    voucher.isCrossMerchant
                                        ? 'Áp dụng toàn quốc cho hệ thống ${voucher.targetMerchantName} (Tài trợ bởi ${voucher.merchantName})'
                                        : 'Áp dụng toàn quốc cho thương hiệu ${voucher.merchantName}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Cách dùng & Điều kiện',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildConditionItem(
                              'Phạm vi áp dụng:',
                              voucher.isCrossMerchant
                                  ? 'Áp dụng thanh toán trực tiếp tại toàn bộ chi nhánh của ${voucher.targetMerchantName} trên toàn quốc.'
                                  : 'Áp dụng khi dùng bữa tại chỗ hoặc mang đi tại cửa hàng.',
                            ),
                            const Divider(height: 24, color: AppColors.border),
                            _buildConditionItem(
                              'Hạn mức sử dụng:',
                              voucher.isCrossMerchant
                                  ? 'Mỗi voucher dùng 01 lần. Đưa mã barcode cho thu ngân ${voucher.targetMerchantName} lúc thanh toán.'
                                  : 'Mỗi voucher được dùng 01 lần. Đưa mã barcode cho thu ngân lúc thanh toán.',
                            ),
                            const Divider(height: 24, color: AppColors.border),
                            _buildConditionItem(
                              'Mô tả chi tiết:',
                              voucher.description ?? 'Ưu đãi dành riêng cho thành viên TingTing.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ==========================================
          // BOTTOM FIXED BAR (NEO CẠNH DƯỚI)
          // ==========================================
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Cột giá điểm
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Giá đổi thưởng',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 2),
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
                            '${voucher.pointsCost} VUI',
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
                  const SizedBox(width: 20),

                  // Nút Đổi ngay
                  Expanded(
                    child: PrimaryButton(
                      label: 'Đổi ngay',
                      isLoading: myVoucherState.isRedeeming,
                      onPressed: () => _handleRedeem(voucher),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionItem(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
