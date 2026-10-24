/// File: widget_test.dart
/// Module: Tests
/// Description: Bộ kiểm thử tự động (Unit & Widget Tests) cho TingTing Merchant App.
///
/// Responsibility:
///   - Kiểm thử hiển thị và tương tác của ActionButton (filled, outlined, loading)
///   - Kiểm thử hiển thị của TransactionTile (tính toán delta điểm, format tiền)
///   - Kiểm thử Model Serialization (Merchant, MerchantReport, MerchantVoucher)
///   - Kiểm thử khởi tạo MerchantApp và màn hình đăng nhập
///
/// Dependencies:
///   - package:flutter/material.dart
///   - package:flutter_test/flutter_test.dart
///   - package:flutter_riverpod/flutter_riverpod.dart
///   - app_merchant/...
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app_merchant/main.dart';
import 'package:app_merchant/models/merchant_model.dart';
import 'package:app_merchant/models/report_model.dart';
import 'package:app_merchant/models/merchant_voucher_model.dart';
import 'package:app_merchant/widgets/action_button.dart';
import 'package:app_merchant/widgets/transaction_tile.dart';

void main() {
  group('1. Unit Tests - Models', () {
    test('Merchant.fromJson & toJson', () {
      final json = {
        'id': 'm-123',
        'name': 'Highlands Coffee',
        'email': 'highlands@tingting.dev',
        'category': 'F&B',
        'qr_static_code': 'QR_HIGHLANDS',
      };

      final merchant = Merchant.fromJson(json);
      expect(merchant.id, 'm-123');
      expect(merchant.name, 'Highlands Coffee');
      expect(merchant.email, 'highlands@tingting.dev');
      expect(merchant.category, 'F&B');
      expect(merchant.qrStaticCode, 'QR_HIGHLANDS');

      final serialized = merchant.toJson();
      expect(serialized['id'], 'm-123');
      expect(serialized['name'], 'Highlands Coffee');
    });

    test('MerchantReport.fromJson', () {
      final json = {
        'active_vouchers_count': 5,
        'total_points_issued': 12000,
        'total_transactions': 45,
        'used_vouchers_count': 12,
      };

      final report = MerchantReport.fromJson(json);
      expect(report.activeVouchersCount, 5);
      expect(report.totalPointsIssued, 12000);
      expect(report.totalTransactions, 45);
      expect(report.usedVouchersCount, 12);
    });

    test('MerchantVoucher properties (isActive, isExpired, isOutOfStock)', () {
      final futureDate = DateTime.now().add(const Duration(days: 10));
      final pastDate = DateTime.now().subtract(const Duration(days: 1));

      final activeVoucher = MerchantVoucher(
        id: 'v-1',
        merchantId: 'm-1',
        title: 'Giảm 20k',
        pointsCost: 200,
        totalQuantity: 50,
        remainingQuantity: 25,
        expiredAt: futureDate,
      );
      expect(activeVoucher.isActive, isTrue);
      expect(activeVoucher.isExpired, isFalse);
      expect(activeVoucher.isOutOfStock, isFalse);

      final expiredVoucher = MerchantVoucher(
        id: 'v-2',
        merchantId: 'm-1',
        title: 'Hết hạn',
        pointsCost: 200,
        totalQuantity: 50,
        remainingQuantity: 25,
        expiredAt: pastDate,
      );
      expect(expiredVoucher.isExpired, isTrue);
      expect(expiredVoucher.isActive, isFalse);

      final outOfStockVoucher = MerchantVoucher(
        id: 'v-3',
        merchantId: 'm-1',
        title: 'Hết lượt',
        pointsCost: 200,
        totalQuantity: 50,
        remainingQuantity: 0,
        expiredAt: futureDate,
      );
      expect(outOfStockVoucher.isOutOfStock, isTrue);
      expect(outOfStockVoucher.isActive, isFalse);
    });

    test('MerchantVoucher.fromJson parses cross-merchant co-branding voucher correctly', () {
      final json = {
        'id': 'v-cross-2',
        'merchant_id': 'm-highlands',
        'target_merchant_id': 'm-cgv',
        'title': 'Highlands x CGV: Vé 2D',
        'points_cost': 500,
        'total_quantity': 100,
        'remaining_quantity': 80,
        'expired_at': '2026-12-31T23:59:59.000Z',
        'merchant': {'name': 'Highlands Coffee'},
        'target_merchant': {'name': 'CGV Cinemas'},
      };

      final voucher = MerchantVoucher.fromJson(json);
      expect(voucher.id, 'v-cross-2');
      expect(voucher.targetMerchantId, 'm-cgv');
      expect(voucher.targetMerchantName, 'CGV Cinemas');
      expect(voucher.issuerMerchantName, 'Highlands Coffee');
      expect(voucher.isCrossMerchant, isTrue);
    });
  });

  group('2. Widget Tests - Shared Widgets', () {
    testWidgets('ActionButton renders label and triggers callback', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionButton(
              label: 'Quét mã QR',
              icon: Icons.qr_code_scanner,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Quét mã QR'), findsOneWidget);
      expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);

      await tester.tap(find.byType(ActionButton));
      await tester.pump();
      expect(pressed, isTrue);
    });

    testWidgets('ActionButton shows loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionButton(
              label: 'Đang xử lý',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Đang xử lý'), findsNothing);
    });

    testWidgets('TransactionTile renders earn transaction correctly', (tester) async {
      final tileData = TransactionTileData(
        type: TransactionType.earnPoints,
        subject: 'Nguyễn Hoàng Nam (090****001)',
        pointsDelta: 250,
        billAmount: 2500000,
        createdAt: DateTime(2026, 10, 23, 14, 30),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionTile(data: tileData),
          ),
        ),
      );

      expect(find.text('Cộng điểm'), findsOneWidget);
      expect(find.text('Nguyễn Hoàng Nam (090****001)'), findsOneWidget);
      expect(find.text('+250 điểm'), findsOneWidget);
      expect(find.text('Hóa đơn: 2.500.000đ'), findsOneWidget);
    });
  });

  group('3. Widget Tests - Merchant App Smoke Test', () {
    testWidgets('MerchantApp boots and displays Merchant Login Screen', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MerchantApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Mặc định ban đầu chưa đăng nhập -> hiển thị màn hình Login
      expect(find.text('TingTing Merchant'), findsOneWidget);
      expect(find.text('Cổng Quản Trị & Tích Điểm Thành Viên'), findsOneWidget);
      expect(find.text('Đăng nhập vào hệ thống'), findsOneWidget);
      expect(find.text('Tài khoản Demo (1-Chạm Kiểm Thử)'), findsOneWidget);
    });
  });
}
