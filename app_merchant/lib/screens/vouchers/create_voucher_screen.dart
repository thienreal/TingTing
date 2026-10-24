/// File: create_voucher_screen.dart
/// Module: Screens/Vouchers
/// Description: Màn hình Tạo Deal Ưu Đãi Mới cho Cửa hàng đối tác.
///
/// Responsibility:
///   - Nhập thông tin: Tiêu đề, Mô tả, Hạn mức điểm đổi (points_cost), Số lượng, Ngày hết hạn
///   - Live Preview thẻ voucher thời gian thực khi người dùng nhập liệu
///   - Gọi POST /merchants/vouchers và thông báo kết quả
///
/// Dependencies:
///   - package:flutter_riverpod/flutter_riverpod.dart
///   - app_merchant/lib/core/theme.dart
///   - app_merchant/lib/providers/merchant_voucher_provider.dart
///   - app_merchant/lib/widgets/action_button.dart
///
/// Todo:
///   - [ ] Bổ sung chọn ảnh voucher từ thư viện máy ảnh
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/merchant_auth_provider.dart';
import '../../providers/merchant_voucher_provider.dart';
import '../../widgets/action_button.dart';

class CreateVoucherScreen extends ConsumerStatefulWidget {
  const CreateVoucherScreen({super.key});

  @override
  ConsumerState<CreateVoucherScreen> createState() => _CreateVoucherScreenState();
}

class _CreateVoucherScreenState extends ConsumerState<CreateVoucherScreen> {
  final _titleController = TextEditingController(text: 'Giảm 30.000đ cho hóa đơn từ 100k');
  final _descController = TextEditingController(
    text: 'Áp dụng cho toàn bộ đồ uống tại các chi nhánh. Không áp dụng cùng CTKM khác.',
  );
  final _pointsCostController = TextEditingController(text: '300');
  final _quantityController = TextEditingController(text: '50');
  DateTime _expiredAt = DateTime.now().add(const Duration(days: 30));

  // Loại ưu đãi: false = Nội bộ quán, true = Liên kết kích cầu đối tác
  bool _isCrossMerchant = false;
  String? _selectedTargetMerchantId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(merchantVoucherProvider.notifier).fetchNetworkPartners();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _pointsCostController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiredAt,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.action,
              onPrimary: Colors.white,
              surface: AppColors.card,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _expiredAt = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
      });
    }
  }

  void _onSubmit() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    final pointsCost = int.tryParse(_pointsCostController.text.trim());
    final totalQuantity = int.tryParse(_quantityController.text.trim());

    if (title.isEmpty) {
      _showToast('Vui lòng nhập tiêu đề ưu đãi');
      return;
    }

    if (pointsCost == null || pointsCost <= 0) {
      _showToast('Số điểm cần đổi phải lớn hơn 0');
      return;
    }

    if (totalQuantity == null || totalQuantity <= 0) {
      _showToast('Số lượng phát hành phải lớn hơn 0');
      return;
    }

    if (_isCrossMerchant && (_selectedTargetMerchantId == null || _selectedTargetMerchantId!.isEmpty)) {
      _showToast('Vui lòng chọn đối tác trong liên minh để áp dụng ưu đãi');
      return;
    }

    final success = await ref.read(merchantVoucherProvider.notifier).createVoucher(
          title: title,
          description: desc.isNotEmpty ? desc : null,
          pointsCost: pointsCost,
          totalQuantity: totalQuantity,
          expiredAt: _expiredAt,
          targetMerchantId: _isCrossMerchant ? _selectedTargetMerchantId : null,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Phát hành ưu đãi "$title" thành công!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.action,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final voucherState = ref.watch(merchantVoucherProvider);
    final currentMerchant = ref.watch(merchantAuthProvider).merchant;

    // Lọc các đối tác khác quán hiện tại
    final availablePartners = voucherState.networkPartners
        .where((p) => p.id != currentMerchant?.id)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tạo Deal Ưu Đãi Mới'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==========================================
            // THẺ XEM TRƯỚC (LIVE CARD PREVIEW)
            // ==========================================
            const Row(
              children: [
                Icon(Icons.remove_red_eye_outlined, size: 18, color: AppColors.textSecondary),
                SizedBox(width: 6),
                Text(
                  'Xem trước thẻ ưu đãi khách hàng nhìn thấy:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildLivePreviewCard(currentMerchant?.name ?? 'Quán của bạn', availablePartners),
            const SizedBox(height: 24),

            // ==========================================
            // FORM NHẬP THÔNG TIN
            // ==========================================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin ưu đãi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),

                  // ==========================================
                  // CHỌN LOẠI ƯU ĐÃI: NỘI BỘ vs LIÊN KẾT ĐỐI TÁC
                  // ==========================================
                  _buildLabel('Phạm vi áp dụng ưu đãi *'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTypeOption(
                          isSelected: !_isCrossMerchant,
                          icon: Icons.storefront_rounded,
                          title: 'Nội bộ quán',
                          subtitle: 'Áp dụng tại quán bạn',
                          onTap: () {
                            setState(() {
                              _isCrossMerchant = false;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTypeOption(
                          isSelected: _isCrossMerchant,
                          icon: Icons.handshake_rounded,
                          title: 'Deal liên kết',
                          subtitle: 'Kích cầu đối tác chéo',
                          onTap: () {
                            setState(() {
                              _isCrossMerchant = true;
                              if (_selectedTargetMerchantId == null && availablePartners.isNotEmpty) {
                                _selectedTargetMerchantId = availablePartners.first.id;
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ==========================================
                  // DROPDOWN CHỌN ĐỐI TÁC LIÊN MINH
                  // ==========================================
                  if (_isCrossMerchant) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9E6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.hub_rounded, size: 18, color: Color(0xFFB38600)),
                              SizedBox(width: 6),
                              Text(
                                'Chọn đối tác thụ hưởng trong liên minh TingTing:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF7A5C00),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedTargetMerchantId ?? (availablePartners.isNotEmpty ? availablePartners.first.id : null),
                                hint: const Text('Chọn đối tác áp dụng voucher'),
                                items: availablePartners.map((partner) {
                                  return DropdownMenuItem<String>(
                                    value: partner.id,
                                    child: Row(
                                      children: [
                                        const Icon(Icons.store_rounded, size: 18, color: AppColors.action),
                                        const SizedBox(width: 8),
                                        Text(
                                          partner.name,
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                        ),
                                        if (partner.category.isNotEmpty) ...[
                                          const SizedBox(width: 6),
                                          Text(
                                            '(${partner.category})',
                                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedTargetMerchantId = val;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Khách hàng sẽ mang voucher do quán bạn phát hành sang đối tác này để quét sử dụng.',
                            style: TextStyle(fontSize: 11, color: Color(0xFF8A6D0B), height: 1.3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Tiêu đề
                  _buildLabel('Tiêu đề voucher *'),
                  TextField(
                    controller: _titleController,
                    onChanged: (_) => setState(() {}),
                    decoration: _inputDecoration(
                      hint: 'VD: Giảm 50.000đ cho đơn từ 200k',
                      icon: Icons.title_rounded,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mô tả
                  _buildLabel('Mô tả & Điều kiện áp dụng'),
                  TextField(
                    controller: _descController,
                    maxLines: 2,
                    onChanged: (_) => setState(() {}),
                    decoration: _inputDecoration(
                      hint: 'Nhập điều kiện, hạn chế áp dụng...',
                      icon: Icons.description_outlined,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hàng: Điểm cần đổi & Số lượng phát hành
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Điểm đổi (VUI) *'),
                            TextField(
                              controller: _pointsCostController,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                              decoration: _inputDecoration(
                                hint: '300',
                                icon: Icons.monetization_on_outlined,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Số lượng phát hành *'),
                            TextField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                              decoration: _inputDecoration(
                                hint: '50',
                                icon: Icons.inventory_2_outlined,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Ngày hết hạn
                  _buildLabel('Thời hạn sử dụng *'),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.event_rounded, size: 20, color: AppColors.textSecondary),
                              const SizedBox(width: 10),
                              Text(
                                '${_expiredAt.day.toString().padLeft(2, '0')}/${_expiredAt.month.toString().padLeft(2, '0')}/${_expiredAt.year}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'Thay đổi',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.action,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Thông báo lỗi nếu có
                  if (voucherState.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.actionLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        voucherState.errorMessage!,
                        style: const TextStyle(color: AppColors.action, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Nút Submit
                  ActionButton(
                    label: _isCrossMerchant
                        ? 'Phát hành Deal Liên Kết Ngay'
                        : 'Phát hành ưu đãi ngay',
                    icon: _isCrossMerchant ? Icons.handshake_rounded : Icons.rocket_launch_rounded,
                    isLoading: voucherState.isCreating,
                    onPressed: _onSubmit,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption({
    required bool isSelected,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryDark : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.primaryDark),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppColors.textPrimary.withValues(alpha: 0.7) : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLivePreviewCard(String currentMerchantName, List<dynamic> availablePartners) {
    final title = _titleController.text.trim().isEmpty
        ? 'Tên ưu đãi của bạn'
        : _titleController.text.trim();
    final points = _pointsCostController.text.trim().isEmpty
        ? '0'
        : _pointsCostController.text.trim();
    final quantity = _quantityController.text.trim().isEmpty
        ? '0'
        : _quantityController.text.trim();

    String? targetName;
    if (_isCrossMerchant && _selectedTargetMerchantId != null) {
      try {
        final match = availablePartners.firstWhere((p) => p.id == _selectedTargetMerchantId);
        targetName = match.name;
      } catch (_) {}
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isCrossMerchant ? AppColors.action : AppColors.primary,
          width: 1.5,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner liên kết đối tác
          if (_isCrossMerchant) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.actionLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.handshake_rounded, size: 14, color: AppColors.action),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '🤝 LIÊN KẾT: $currentMerchantName ➔ ${targetName ?? "Đối tác TingTing"}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.action,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _isCrossMerchant ? AppColors.actionLight : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    _isCrossMerchant ? Icons.stars_rounded : Icons.card_giftcard_rounded,
                    color: _isCrossMerchant ? AppColors.action : AppColors.primaryDark,
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
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isCrossMerchant && targetName != null
                          ? 'Áp dụng tại: $targetName • SL: $quantity'
                          : 'Phát hành $quantity voucher • HSD: ${_expiredAt.day}/${_expiredAt.month}/${_expiredAt.year}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on_rounded, size: 14, color: AppColors.textPrimary),
                    const SizedBox(width: 4),
                    Text(
                      '$points VUI',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.inputBackground,
      prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}

