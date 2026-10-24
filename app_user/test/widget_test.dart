/// File: widget_test.dart
/// Module: Tests
/// Description: Bộ kiểm thử đơn vị và giao diện (Unit & Widget Test) cho TingTing User App.
///
/// Responsibility:
///   - Kiểm thử render PrimaryButton và sự kiện bấm nút
///   - Kiểm thử render TicketContainer với notch
///   - Kiểm thử parse JSON cho UserModel, VoucherModel
///
/// Dependencies:
///   - package:flutter/material.dart
///   - package:flutter_test/flutter_test.dart
///   - package:app_user/widgets/primary_button.dart
///   - package:app_user/widgets/ticket_notch_clipper.dart
///   - package:app_user/models/user_model.dart
///   - package:app_user/models/voucher_model.dart
///
/// Todo:
///   (File đã hoàn thiện)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_user/widgets/primary_button.dart';
import 'package:app_user/widgets/ticket_notch_clipper.dart';
import 'package:app_user/models/user_model.dart';
import 'package:app_user/models/voucher_model.dart';
import 'package:app_user/screens/auth/phone_input_screen.dart';

void main() {
  group('TingTing User App Widget Tests', () {
    testWidgets('PrimaryButton displays label and responds to tap', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Đổi ngay',
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      // Kiểm tra nhãn hiển thị
      expect(find.text('Đổi ngay'), findsOneWidget);

      // Bấm nút
      await tester.tap(find.text('Đổi ngay'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('PrimaryButton shows loading indicator when isLoading is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Đang xử lý',
              isLoading: true,
              onPressed: null,
            ),
          ),
        ),
      );

      // Kiểm tra có CircularProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('TicketContainer renders child properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TicketContainer(
              notchRadius: 10,
              notchPosition: 0.5,
              child: const Text('Voucher 50k KFC'),
            ),
          ),
        ),
      );

      expect(find.text('Voucher 50k KFC'), findsOneWidget);
    });

    testWidgets('PhoneInputScreen renders phone field and enables button on 10 digits', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PhoneInputScreen(),
          ),
        ),
      );

      // Ban đầu nút Tiếp tục bị vô hiệu hóa
      expect(find.text('Tiếp tục'), findsOneWidget);
      expect(find.text('Số điện thoại'), findsOneWidget);

      // Nhập 10 chữ số hợp lệ
      await tester.enterText(find.byType(TextField), '0900000001');
      await tester.pump();

      // Nút Tiếp tục bây giờ khả dụng (không bị null onPressed)
      final primaryButton = tester.widget<PrimaryButton>(find.byType(PrimaryButton));
      expect(primaryButton.onPressed, isNotNull);
    });
  });

  group('TingTing Models Unit Tests', () {
    test('UserModel.fromJson parses correctly', () {
      final json = {
        'id': 'user-123',
        'phone_number': '0900000001',
        'full_name': 'Nguyễn Văn A',
        'total_points': 1500,
        'membership_tier': 'SILVER',
        'created_at': '2026-10-23T00:00:00.000Z',
      };

      final user = UserModel.fromJson(json);
      expect(user.id, 'user-123');
      expect(user.phoneNumber, '0900000001');
      expect(user.fullName, 'Nguyễn Văn A');
      expect(user.totalPoints, 1500);
      expect(user.membershipTier, 'SILVER');
      expect(user.displayName, 'Nguyễn Văn A');
    });

    test('VoucherModel.fromJson parses correctly with merchant', () {
      final json = {
        'id': 'v-1',
        'merchant_id': 'm-1',
        'title': 'Giảm 50% Pizza',
        'points_cost': 500,
        'total_quantity': 100,
        'remaining_quantity': 42,
        'expired_at': '2026-12-31T23:59:59.000Z',
        'merchant': {
          'id': 'm-1',
          'name': 'The Pizza Company',
          'category': 'F&B',
        },
      };

      final voucher = VoucherModel.fromJson(json);
      expect(voucher.id, 'v-1');
      expect(voucher.title, 'Giảm 50% Pizza');
      expect(voucher.pointsCost, 500);
      expect(voucher.merchantName, 'The Pizza Company');
      expect(voucher.isExpired, isFalse);
      expect(voucher.isCrossMerchant, isFalse);
    });

    test('VoucherModel.fromJson parses cross-merchant co-branding voucher correctly', () {
      final json = {
        'id': 'v-cross-1',
        'merchant_id': 'm-highlands',
        'target_merchant_id': 'm-cgv',
        'title': 'Highlands x CGV: Tặng vé xem phim 2D',
        'points_cost': 500,
        'total_quantity': 200,
        'remaining_quantity': 150,
        'expired_at': '2026-12-31T23:59:59.000Z',
        'merchant': {
          'id': 'm-highlands',
          'name': 'Highlands Coffee',
          'category': 'F&B',
        },
        'target_merchant': {
          'id': 'm-cgv',
          'name': 'CGV Cinemas',
          'category': 'Giải trí',
        },
      };

      final voucher = VoucherModel.fromJson(json);
      expect(voucher.id, 'v-cross-1');
      expect(voucher.merchantName, 'Highlands Coffee');
      expect(voucher.targetMerchantName, 'CGV Cinemas');
      expect(voucher.isCrossMerchant, isTrue);
      expect(voucher.realImageUrl, contains('unsplash'));
    });
  });
}
