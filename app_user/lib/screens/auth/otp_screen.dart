/// File: otp_screen.dart
/// Module: AuthFeature
/// Description: Màn hình nhập mã xác thực OTP 6 chữ số của User App.
///   Thiết kế chuẩn theo mẫu anh/9ab7764620fda1a3f8ec5.jpg.
///
/// Responsibility:
///   - Hiển thị 6 ô nhập mã OTP tách biệt với viền bo tròn 12px
///   - Đếm ngược 60s cho việc gửi lại mã
///   - Gọi API POST /auth/verify-otp với mã OTP (mock 000000)
///   - Điều hướng vào Trang chủ sau khi xác thực thành công
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/primary_button.dart';
import '../../providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final TextEditingController _otpHiddenController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int _countdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    // Tự động focus vào ô nhập OTP khi mở màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpHiddenController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _handleVerify() async {
    final otp = _otpHiddenController.text.trim();
    if (otp.length != 6) return;

    final success = await ref.read(authProvider.notifier).verifyOtp(otp);

    if (!mounted) return;

    if (success) {
      // Chuyển hướng đến màn hình chính sau khi xác thực thành công
      context.go('/home');
    } else {
      final error = ref.read(authProvider).errorMessage ?? 'Mã OTP không chính xác';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.action,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      _otpHiddenController.clear();
      setState(() {});
    }
  }

  Future<void> _handleResend() async {
    final phone = ref.read(authProvider).currentPhoneNumber;
    if (phone != null) {
      await ref.read(authProvider.notifier).sendOtp(phone);
      _startCountdown();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã gửi lại mã OTP (Mã thử nghiệm: 000000)'),
          backgroundColor: AppColors.textPrimary,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final phone = authState.currentPhoneNumber ?? '---';
    final currentOtp = _otpHiddenController.text;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF9DB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==========================================
            // HEADER BANNER VÀNG
            // ==========================================
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFF9DB), AppColors.primaryLight],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chào mừng bạn đến',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'TingTing',
                          style: TextStyle(
                            fontSize: 32,
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
                  Container(
                    width: 75,
                    height: 75,
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
                      child: Text('🐤', style: TextStyle(fontSize: 40)),
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================
            // KHỐI NHẬP 6 Ô OTP
            // ==========================================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      'Mã OTP đã được gửi đến số $phone',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),

                    // Gợi ý mã OTP cho MVP
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '💡 Gợi ý thử nghiệm: Mã OTP mặc định là 000000',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF996500),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 6 Ô vuông hiển thị chữ số OTP
                    GestureDetector(
                      onTap: () => _focusNode.requestFocus(),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // TextField ẩn để nhận input từ bàn phím
                          Opacity(
                            opacity: 0.0,
                            child: TextField(
                              controller: _otpHiddenController,
                              focusNode: _focusNode,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              onChanged: (val) {
                                setState(() {});
                                if (val.length == 6) {
                                  _handleVerify();
                                }
                              },
                            ),
                          ),

                          // 6 ô hiển thị giao diện
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) {
                              final hasChar = index < currentOtp.length;
                              final isFocused = index == currentOtp.length;
                              final char = hasChar ? currentOtp[index] : '';

                              return Container(
                                width: 48,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.inputBackground,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isFocused
                                        ? AppColors.action
                                        : (hasChar ? AppColors.textPrimary : AppColors.border),
                                    width: isFocused ? 2 : 1.2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    char,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Đếm ngược và Gửi lại mã
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_countdown > 0)
                          Text(
                            'Gửi lại mã (${_countdown.toString().padLeft(2, '0')}s)',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          )
                        else
                          TextButton(
                            onPressed: _handleResend,
                            child: const Text(
                              'Gửi lại mã',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.action,
                              ),
                            ),
                          ),
                        const Text(' hoặc ', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: const Text(
                            'Đổi số điện thoại',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Nút xác thực tiếp tục
                    PrimaryButton(
                      label: 'Tiếp tục',
                      isLoading: authState.isLoading,
                      onPressed: currentOtp.length == 6 ? _handleVerify : null,
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
