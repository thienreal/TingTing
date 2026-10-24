/// File: scan_screen.dart
/// Module: Screens/Scan
/// Description: Màn hình Quét mã đa năng cho Thu ngân: Tích điểm & Trừ Voucher.
///
/// Responsibility:
///   - 2 Chế độ hoạt động: Tích điểm (Quét QR User) & Trừ voucher (Quét barcode/QR UserVoucher)
///   - Camera scanner tích hợp MobileScanner có errorBuilder an toàn
///   - Ô nhập mã thủ công và nút "Nạp dữ liệu mẫu nhanh" hỗ trợ máy ảo/desktop
///   - Hộp thoại nhập số tiền hóa đơn tự động tính điểm VUI theo thời gian thực
///   - Dialog chúc mừng thành công với hiệu ứng trực quan sinh động
///
/// Dependencies:
///   - package:mobile_scanner/mobile_scanner.dart
///   - package:flutter_riverpod/flutter_riverpod.dart
///   - app_merchant/lib/core/theme.dart
///   - app_merchant/lib/providers/scanner_provider.dart
///   - app_merchant/lib/widgets/action_button.dart
///
/// Todo:
///   - [ ] Bổ sung âm thanh "TingTing" khi quét mã thành công
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/theme.dart';
import '../../providers/scanner_provider.dart';

enum ScanMode { earnPoints, useVoucher }

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  ScanMode _currentMode = ScanMode.earnPoints;
  late final MobileScannerController _scannerController;
  final _manualCodeController = TextEditingController();
  final _billAmountController = TextEditingController(text: '250000');
  bool _isCameraActive = true;
  bool _hasScanned = false;
  bool _isTorchOn = false;

  // Dữ liệu mẫu phục vụ kiểm thử nhanh (User 0900000001)
  static const String demoUserId = '00000000-0000-0000-0000-000000000001';
  static const String demoVoucherId = '11111111-1111-1111-1111-111111111101';

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _manualCodeController.dispose();
    _billAmountController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue != null && barcode!.rawValue!.isNotEmpty) {
      _hasScanned = true;
      _handleCodeScanned(barcode.rawValue!);
    }
  }

  void _handleCodeScanned(String code) {
    _manualCodeController.text = code;
    if (_currentMode == ScanMode.earnPoints) {
      _showBillAmountDialog(code);
    } else {
      _confirmUseVoucher(code);
    }
  }

  void _showBillAmountDialog(String userId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final billText = _billAmountController.text.replaceAll(RegExp(r'[^0-9]'), '');
            final billAmount = double.tryParse(billText) ?? 0.0;
            final expectedPoints = (billAmount / 1000).floor();

            return AlertDialog(
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.receipt_long, color: AppColors.primaryDark),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Nhập hóa đơn',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person_pin, size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'User: $userId',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Số tiền thanh toán (VNĐ)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _billAmountController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      suffixText: 'đ',
                      suffixStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 16),
                  // Thẻ tự tính điểm
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.monetization_on_rounded, color: AppColors.primaryDark, size: 22),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Điểm VUI khách nhận được:',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                            Text(
                              '+$expectedPoints VUI (1.000đ = 1 điểm)',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _hasScanned = false;
                    Navigator.pop(ctx);
                  },
                  child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final success = await ref.read(scannerProvider.notifier).earnPoints(
                          userId: userId,
                          billAmount: billAmount,
                        );
                    if (success && mounted) {
                      _showEarnSuccessDialog();
                    } else if (mounted) {
                      _showErrorSnackBar();
                    }
                    _hasScanned = false;
                  },
                  child: const Text('Xác nhận tích điểm', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmUseVoucher(String userVoucherId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.actionLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.card_giftcard_rounded, color: AppColors.action),
              ),
              const SizedBox(width: 12),
              const Text(
                'Xác nhận Voucher',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bạn có chắc muốn áp dụng và đánh dấu ĐÃ SỬ DỤNG cho mã voucher này?',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SelectableText(
                  userVoucherId,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _hasScanned = false;
                Navigator.pop(ctx);
              },
              child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.action,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                final success = await ref.read(scannerProvider.notifier).useVoucher(
                      userVoucherId: userVoucherId,
                    );
                if (success && mounted) {
                  _showVoucherSuccessDialog();
                } else if (mounted) {
                  _showErrorSnackBar();
                }
                _hasScanned = false;
              },
              child: const Text('Áp dụng ngay', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  void _showEarnSuccessDialog() {
    final result = ref.read(scannerProvider).earnResult;
    if (result == null) return;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.cardShadow,
                ),
                child: const Center(
                  child: Icon(Icons.check_circle_rounded, size: 44, color: AppColors.primaryDark),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tích điểm thành công!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Khách hàng vừa được cộng +${result.pointsEarned} điểm VUI',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildResultRow('Số tiền hóa đơn', '${_formatCurrency(result.billAmount)}đ'),
                    const Divider(height: 16),
                    _buildResultRow('Điểm tích lũy mới', '${result.newTotalPoints} VUI'),
                    const Divider(height: 16),
                    _buildResultRow('Hạng thành viên', result.newMembershipTier),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Hoàn tất', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showVoucherSuccessDialog() {
    final result = ref.read(scannerProvider).voucherResult;
    if (result == null) return;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.actionLight,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.verified_rounded, size: 44, color: AppColors.action),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Áp dụng voucher thành công!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                result.voucherTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.action),
              ),
              if (result.isCrossMerchant) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '🤝 Ưu đãi liên kết tài trợ bởi ${result.issuerMerchantName ?? "Đối tác TingTing"}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 6),
              const Text(
                'Trạng thái đã chuyển sang: ĐÃ SỬ DỤNG (USED)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.action,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Xác nhận & Đóng', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorSnackBar() {
    final error = ref.read(scannerProvider).errorMessage ?? 'Thao tác không thành công';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: AppColors.action,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ],
    );
  }

  String _formatCurrency(double amount) {
    final intAmount = amount.toInt();
    final str = intAmount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(scannerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Quét Mã Giao Dịch',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isCameraActive ? Icons.videocam : Icons.videocam_off,
              color: Colors.white,
            ),
            onPressed: () => setState(() => _isCameraActive = !_isCameraActive),
          ),
          IconButton(
            icon: Icon(
              _isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: () async {
              await _scannerController.toggleTorch();
              setState(() => _isTorchOn = !_isTorchOn);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ==========================================
          // THANH CHUYỂN TAB CHẾ ĐỘ QUÉT
          // ==========================================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.black,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() {
                      _currentMode = ScanMode.earnPoints;
                      _hasScanned = false;
                    }),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _currentMode == ScanMode.earnPoints ? AppColors.primary : Colors.grey[900],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.monetization_on_rounded,
                            size: 18,
                            color: _currentMode == ScanMode.earnPoints ? AppColors.textPrimary : Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Tích điểm',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _currentMode == ScanMode.earnPoints ? AppColors.textPrimary : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() {
                      _currentMode = ScanMode.useVoucher;
                      _hasScanned = false;
                    }),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _currentMode == ScanMode.useVoucher ? AppColors.action : Colors.grey[900],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.card_giftcard_rounded,
                            size: 18,
                            color: _currentMode == ScanMode.useVoucher ? Colors.white : Colors.white70,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Trừ voucher',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _currentMode == ScanMode.useVoucher ? Colors.white : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ==========================================
          // KHUNG QUÉT CAMERA + OVERLAY RADAR
          // ==========================================
          Expanded(
            flex: 5,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_isCameraActive)
                  MobileScanner(
                    controller: _scannerController,
                    onDetect: _onDetect,
                    errorBuilder: (context, error) {
                      return Container(
                        color: Colors.grey[900],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 48),
                              const SizedBox(height: 12),
                              const Text(
                                'Môi trường không có Camera vật lý',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Dùng khung nhập mã thủ công bên dưới để kiểm thử',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                else
                  Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: Text('Camera đã tắt', style: TextStyle(color: Colors.white54)),
                    ),
                  ),

                // Viewfinder Target Frame
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _currentMode == ScanMode.earnPoints ? AppColors.primary : AppColors.action,
                      width: 2.5,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                Positioned(
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _currentMode == ScanMode.earnPoints
                          ? 'Hướng camera vào mã QR của khách'
                          : 'Hướng camera vào Barcode/QR của Voucher',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ==========================================
          // KHỐI NHẬP MÃ THỦ CÔNG & KIỂM THỬ NHANH
          // ==========================================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _currentMode == ScanMode.earnPoints ? 'Nhập User ID thủ công:' : 'Nhập mã UserVoucher ID:',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      // Nút kiểm thử nhanh
                      InkWell(
                        onTap: () {
                          if (_currentMode == ScanMode.earnPoints) {
                            _manualCodeController.text = demoUserId;
                          } else {
                            _manualCodeController.text = demoVoucherId;
                          }
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.bolt, size: 16, color: AppColors.action),
                            Text(
                              'Nạp mã mẫu',
                              style: TextStyle(fontSize: 12, color: AppColors.action, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _manualCodeController,
                          style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                          decoration: InputDecoration(
                            hintText: _currentMode == ScanMode.earnPoints ? 'UUID của khách hàng' : 'UUID của thẻ voucher',
                            hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.inputBackground,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentMode == ScanMode.earnPoints ? AppColors.primary : AppColors.action,
                            foregroundColor: _currentMode == ScanMode.earnPoints ? AppColors.textPrimary : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: scannerState.isProcessing
                              ? null
                              : () {
                                  final code = _manualCodeController.text.trim();
                                  if (code.isEmpty) return;
                                  _handleCodeScanned(code);
                                },
                          child: scannerState.isProcessing
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Xử lý', style: TextStyle(fontWeight: FontWeight.w700)),
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
}
