/// File: phone_input_screen.dart
/// Module: AuthFeature
/// Description: Màn hình nhập số điện thoại đăng nhập/đăng ký của User App.
///   Thiết kế chuẩn theo mẫu anh/0620cad59c6e1d30447f3.jpg.
///
/// Responsibility:
///   - Cho phép người dùng nhập SĐT Việt Nam (10 chữ số)
///   - Kiểm tra tính hợp lệ và gọi API POST /auth/send-otp
///   - Điều hướng sang OtpScreen khi gửi mã thành công
///
/// Dependencies:
///   - package:flutter/material.dart
///   - package:flutter_riverpod/flutter_riverpod.dart
///   - package:go_router/go_router.dart
///   - app_user/lib/core/theme.dart (AppColors)
///   - app_user/lib/widgets/primary_button.dart
///   - app_user/lib/providers/auth_provider.dart
///
/// Todo:
///   (File đã hoàn thiện)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/primary_button.dart';
import '../../providers/auth_provider.dart';

class PhoneInputScreen extends ConsumerStatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  ConsumerState<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends ConsumerState<PhoneInputScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onTextChanged);
    _phoneController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _phoneController.text.trim();
    // Số điện thoại Việt Nam hợp lệ gồm 10 chữ số, bắt đầu bằng 0
    final isValid = RegExp(r'^0[3|5|7|8|9][0-9]{8}$').hasMatch(text);
    if (isValid != _isButtonEnabled) {
      setState(() => _isButtonEnabled = isValid);
    }
  }

  Future<void> _handleContinue() async {
    final phone = _phoneController.text.trim();
    final success = await ref.read(authProvider.notifier).sendOtp(phone);

    if (!mounted) return;

    if (success) {
      context.push('/auth/otp');
    } else {
      final error = ref.read(authProvider).errorMessage ?? 'Không thể gửi mã OTP';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.action,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==========================================
            // HEADER VÀNG VỚI HÌNH LINH VẬT TINGTING
            // ==========================================
            Container(
              height: 220,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFF9DB), AppColors.primaryLight],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Chào mừng bạn đến',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'TingTing',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            foreground: Paint()
                              ..shader = const LinearGradient(
                                colors: [Color(0xFFE6A800), Color(0xFFC78200)],
                              ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Linh vật hình trái chanh/vịt vàng biểu tượng
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🐤', style: TextStyle(fontSize: 48)),
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================
            // FORM NHẬP SỐ ĐIỆN THOẠI
            // ==========================================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Số điện thoại',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        // Hộp tiền tố +84 cờ Việt Nam
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.inputBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Row(
                            children: [
                              Text('⭐', style: TextStyle(fontSize: 16)),
                              SizedBox(width: 6),
                              Text(
                                '+84',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Ô nhập SĐT
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Nhập số điện thoại (vd: 0900000001)',
                              hintStyle: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              counterText: '',
                              filled: true,
                              fillColor: AppColors.inputBackground,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.action, width: 2),
                              ),
                              suffixIcon: _phoneController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                                      onPressed: () => _phoneController.clear(),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      'Lưu ý: Tài khoản mẫu từ Seed Data có sẵn: 0900000001 đến 0900000020 (OTP: 000000).',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),

                    const Spacer(),

                    // Nút tiếp tục dưới đáy màn hình
                    PrimaryButton(
                      label: 'Tiếp tục',
                      isLoading: authState.isLoading,
                      onPressed: _isButtonEnabled ? _handleContinue : null,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
