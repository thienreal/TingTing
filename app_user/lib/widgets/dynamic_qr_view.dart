/// File: dynamic_qr_view.dart
/// Module: SharedWidgets
/// Description: Widget hiển thị mã QR động (Dynamic QR Code) định danh của người dùng.
///   Tự động làm mới mỗi 60 giây để chống chụp màn hình gian lận, kèm vòng đếm ngược.
///
/// Responsibility:
///   - Sinh mã QR chứa chuỗi định danh kèm timestamp theo thời gian thực
///   - Đếm ngược 60s và tự động sinh mã mới khi hết hạn
///   - Cho phép người dùng bấm nút làm mới thủ công
///
/// Dependencies:
///   - package:qr_flutter/qr_flutter.dart
///   - app_user/lib/core/theme.dart (AppColors)
///   - app_user/lib/core/constants.dart
///
/// Todo:
///   (File đã hoàn thiện)
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../core/theme.dart';
import '../core/constants.dart';

class DynamicQrView extends StatefulWidget {
  final String userId;
  final double size;

  const DynamicQrView({
    super.key,
    required this.userId,
    this.size = 220,
  });

  @override
  State<DynamicQrView> createState() => _DynamicQrViewState();
}

class _DynamicQrViewState extends State<DynamicQrView> {
  late int _remainingSeconds;
  Timer? _timer;
  late int _generatedTimestamp;

  @override
  void initState() {
    super.initState();
    _resetQr();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetQr() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = AppConstants.dynamicQrRefreshSeconds;
      _generatedTimestamp = DateTime.now().millisecondsSinceEpoch;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        // Hết 60s -> Tự động sinh mã mới
        _resetQr();
      }
    });
  }

  /// Chuỗi payload được mã hóa trong QR code
  /// Format chuẩn: `tingting:earn:<userId>:<timestamp>`
  /// Giúp Merchant App giải mã và xác thực QR còn hạn
  String get _qrData => 'tingting:earn:${widget.userId}:$_generatedTimestamp';

  @override
  Widget build(BuildContext context) {
    final progress = _remainingSeconds / AppConstants.dynamicQrRefreshSeconds;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ==========================================
          // QR CODE VIEW
          // ==========================================
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: QrImageView(
              data: _qrData,
              version: QrVersions.auto,
              size: widget.size,
              gapless: true,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.textPrimary,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 18),

          // ==========================================
          // ĐỒNG HỒ ĐẾM NGƯỢC & NÚT LÀM MỚI
          // ==========================================
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 2.5,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _remainingSeconds <= 10 ? AppColors.action : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Mã tự làm mới sau ${_remainingSeconds}s',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _resetQr,
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.refresh_rounded, size: 20, color: AppColors.action),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          const Text(
            'Đưa mã này cho thu ngân để quét và tích điểm',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
