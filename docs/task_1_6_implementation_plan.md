# Kế Hoạch Triển Khai Task 1.6: Hoàn Thiện Mobile App - User App (Flutter)

Dự án TingTing cần phát triển toàn diện **Task 1.6: Mobile App - User App** (`app_user/`) trên nền tảng Flutter, đảm bảo giao diện đẹp mắt, sắc nét và đạt chuẩn chất lượng của một **sản phẩm hoàn thiện** (Production-grade MVP). Giao diện bám sát 100% tài liệu thiết kế [UI_Design_Rules.md](UI_Design_Rules.md) và các ảnh mẫu thực tế trong thư mục `anh/` (màu Vàng chủ đạo `#FAD240`, Hồng/Đỏ san hô action `#E8687D`, card bo góc 16px, ticket notch, pill search bar, shadow nhạt).

---

## User Review Required

> [!IMPORTANT]
> **Các quyết định kỹ thuật & thiết kế quan trọng cần thống nhất:**
> 1. **Kiến trúc State Management:** Sử dụng **Flutter Riverpod** để quản lý trạng thái tập trung (Auth state, User profile & điểm số, Danh sách Voucher, Giỏ voucher đã đổi, Socket notifications).
> 2. **Điều hướng (Navigation):** Sử dụng **GoRouter** với ShellRoute cho 4 tab Bottom Navigation (`/home`, `/earn`, `/rewards`, `/account`) và các route con (`/auth/phone`, `/auth/otp`, `/voucher/:id`, `/my-vouchers`, `/my-voucher/:id`, `/transactions`).
> 3. **Dynamic QR Code:** Tab "Tích điểm" sẽ sinh mã QR động gồm `userId` + timestamp có hiệu lực và tự làm mới mỗi 60 giây (kèm đồng hồ đếm ngược và vòng tròn hiệu ứng chuyển động) để Merchant quét cộng điểm.
> 4. **Vé Voucher (Ticket Notch):** Xây dựng `TicketCard` và `VoucherDetailScreen` với vết cắt bán nguyệt (notch) 2 cạnh bên bằng `CustomClipper` đúng chuẩn thiết kế trong ảnh mẫu.
> 5. **Real-time WebSocket:** Tự động kích hoạt kết nối Socket.IO khi User đăng nhập thành công, tự cập nhật lại số dư điểm và hiển thị thông báo chúc mừng nổi (In-app popup/banner) khi Merchant cộng điểm tại quầy.

---

## Kiến Trúc & Cấu Trúc Thư Mục Đề Xuất

```
app_user/lib/
├── core/
│   ├── theme.dart                 # Màu sắc, font chữ, ThemeData chuẩn UI_Design_Rules
│   ├── api_client.dart            # Cấu hình Dio client, Interceptor thêm Bearer token tự động
│   ├── socket_client.dart         # Socket.IO client (đã có từ Task 1.5, kết nối với Auth state)
│   ├── constants.dart             # Hằng số định cấu hình, key SharedPreferences
│   └── router.dart                # Cấu hình GoRouter điều hướng toàn app
├── models/
│   ├── user_model.dart            # Model User (id, phone, full_name, total_points, membership_tier)
│   ├── voucher_model.dart         # Model Voucher & Merchant liên kết
│   ├── user_voucher_model.dart    # Model UserVoucher (id, voucher_id, status, redeemed_at)
│   └── transaction_model.dart     # Model Transaction (id, type, points_delta, bill_amount, created_at)
├── providers/
│   ├── auth_provider.dart         # Riverpod Notifier quản lý đăng nhập, OTP, lưu JWT token
│   ├── user_provider.dart         # Quản lý thông tin profile, số dư điểm, hạng thành viên
│   ├── voucher_provider.dart      # Quản lý danh sách voucher từ server, bộ lọc category
│   └── my_voucher_provider.dart   # Quản lý danh sách voucher cá nhân, hành động redeem voucher
├── widgets/
│   ├── primary_button.dart        # CTA Button hồng chuẩn (đã có, bổ sung isLoading state)
│   ├── voucher_card.dart          # Card voucher bo góc 16px (đã có, gắn dữ liệu thật)
│   ├── bottom_nav_bar.dart        # 4 tab Navigation Bar (đã có)
│   ├── ticket_notch_clipper.dart  # CustomClipper cắt notch 2 bên thân vé
│   ├── dynamic_qr_view.dart       # Widget hiển thị QR động làm mới mỗi 60s kèm timer tròn
│   └── banner_carousel.dart       # Widget slide ảnh banner khuyến mãi trang chủ
└── screens/
    ├── auth/
    │   ├── phone_input_screen.dart # Màn hình nhập SĐT (+84, mascot TingTing)
    │   └── otp_screen.dart         # Màn hình nhập 6 ô OTP (mock 000000, countdown)
    ├── home/
    │   └── home_screen.dart        # Trang chủ: Header điểm/hạng, Quick Ticket, Banner, Hot deals
    ├── earn/
    │   └── earn_points_screen.dart # Tab Tích điểm: Dynamic QR code 60s, Barcode hội viên, DS đối tác
    ├── rewards/
    │   ├── rewards_screen.dart     # Tab Đổi thưởng: Search pill, Grid phân loại, DS Deal theo danh mục
    │   └── voucher_detail_screen.dart # Chi tiết Voucher: Ảnh lớn, Thẻ vé notch, Điều kiện, Nút Đổi ngay
    ├── my_vouchers/
    │   ├── my_vouchers_screen.dart # Tab/Màn hình Ưu đãi của bạn: Tabs (Đang có, Đã dùng, Hết hạn)
    │   └── my_voucher_barcode_screen.dart # Màn hình Barcode/QR của voucher để thu ngân quét áp dụng
    ├── account/
    │   ├── account_screen.dart     # Tab Tài khoản: Avatar, Hạng thành viên, Lối tắt tiện ích, Đăng xuất
    │   └── transaction_history_screen.dart # Lịch sử tích điểm & đổi quà (+/- điểm, ngày giờ)
    └── main_shell.dart             # Khung điều hướng BottomNavBar bọc 4 tab
```

---

## Chi Tiết Các Màn Hình & Trải Nghiệm Hoàn Thiện

### 1. Phân Hệ Xác Thực (Auth Flow)
* **PhoneInputScreen:**
  * Header vàng bo lượn sóng nhẹ với linh vật TingTing đáng yêu.
  * Ô nhập số điện thoại với tiền tố `+84`, kiểm tra định dạng số điện thoại Việt Nam (10 chữ số, đầu số hợp lệ).
  * Nút "Tiếp tục" màu hồng `#E8687D` (vô hiệu hóa cho đến khi nhập đủ 10 số).
  * Gọi API `POST /auth/send-otp`.
* **OtpScreen:**
  * Giao diện 6 ô nhập mã OTP tách biệt, tự động nhảy focus sang ô kế tiếp, tự động submit khi nhập đủ 6 số.
  * Đồng hồ đếm ngược 60s cho nút "Gửi lại mã".
  * Gọi API `POST /auth/verify-otp` với mã mock `000000`.
  * Lưu token vào `SharedPreferences`, cập nhật State và chuyển hướng vào `HomeScreen`.

### 2. Trang Chủ (Home Screen)
* **Header:**
  * Avatar linh vật chào hỏi tên người dùng ("Xin chào, [Tên / SĐT]").
  * Ô điểm khả dụng nổi bật ("⚡ [X] Điểm") kèm icon chuông thông báo.
  * Thanh tìm kiếm bo tròn dạng Pill `50px`.
* **Thẻ vé nhanh "Ưu đãi của bạn":**
  * Hiển thị voucher đang sở hữu (nếu có) dưới dạng vé ticket card thu nhỏ với notch 2 bên để bấm xem barcode ngay.
* **Banner Carousel:**
  * Slide tự động chạy các chương trình ưu đãi nổi bật.
* **Các danh mục ưu đãi:**
  * "Ưu đãi mới cập bến" & "Deal hot ăn ngon" với danh sách cuộn ngang thẻ `VoucherCard`. Bấm vào voucher mở `VoucherDetailScreen`.

### 3. Tích Điểm (Earn Points Screen - Dynamic QR)
* **Card thông tin hội viên:**
  * Số điểm khả dụng, hạng hội viên (Standard / Silver / Gold).
  * Mã số thành viên và Barcode định danh.
* **Mã Dynamic QR cốt lõi:**
  * Hiển thị mã QR động lớn ở trung tâm (chứa `{"userId": "...", "timestamp": ...}`).
  * Đồng hồ đếm ngược 60 giây và vòng tròn tiến trình hiển thị thời gian còn lại của mã.
  * Tự động làm mới khi hết thời gian hoặc bấm nút "Làm mới mã".
  * Lời nhắc thân thiện: "Đưa mã này cho thu ngân để quét và tích điểm".
* **Danh sách Thương hiệu đối tác:**
  * Danh sách các cửa hàng áp dụng với logo và số lượng ưu đãi.

### 4. Đổi Thưởng (Rewards Screen & Voucher Detail)
* **RewardsScreen:**
  * Thanh tìm kiếm và bộ lọc thể loại (Tất cả, Ẩm thực, Giải trí, Mua sắm...).
  * Filter chips: "Mới nhất", "Phổ biến", "Điểm thấp nhất".
  * Lưới danh sách voucher đa dạng, hiển thị số điểm cần đổi, tên thương hiệu, ảnh thumbnail.
* **VoucherDetailScreen:**
  * Ảnh hero lớn phía trên.
  * Thẻ vé trung tâm bo góc 16px, có 2 vết khoét bán nguyệt (ticket notch) phân cách thông tin voucher và logo đối tác.
  * Thông tin điều kiện sử dụng, hạn dùng, địa điểm áp dụng.
  * Thanh cố định đáy màn hình (Bottom Fixed Bar): Hiển thị số điểm cần đổi (`points_cost`) + Nút CTA "Đổi ngay".
  * Khi bấm "Đổi ngay": Kiểm tra số dư điểm, hiển thị dialog xác nhận, gọi `POST /vouchers/:id/redeem`. Sau khi thành công hiển thị popup chúc mừng và nút "Xem voucher của tôi".

### 5. Ưu Đãi Của Bạn & Quét Mã Áp Dụng (My Vouchers)
* **MyVouchersScreen:**
  * Hệ thống 3 Tab: "Đang có", "Đã dùng", "Hết hạn" với gạch chân màu hồng `#E8687D` ở tab đang chọn.
  * Danh sách các voucher dưới dạng vé có vạch đứt nét và vết khoét notch.
* **MyVoucherBarcodeScreen:**
  * Dành cho lúc thanh toán tại quầy: Màn hình sáng rõ, hiển thị Barcode lớn và mã ký tự đi kèm (`user_voucher.id`).
  * Nút "Sao chép mã" và hướng dẫn thu ngân quét mã để áp dụng ưu đãi.

### 6. Tài Khoản & Lịch Sử Giao Dịch (Account & History)
* **AccountScreen:**
  * Hiển thị Avatar, Tên người dùng, SĐT, Badge hạng thành viên (Standard/Silver/Gold).
  * Menu danh sách: "Lịch sử tích - đổi điểm", "Ưu đãi của tôi", "Thông tin bảo mật", "Đăng xuất".
* **TransactionHistoryScreen:**
  * Danh sách toàn bộ lịch sử giao dịch (`GET /users/me/transactions`):
    * Giao dịch `EARN`: icon dấu cộng xanh lá `+50 điểm`, số tiền hóa đơn, tên cửa hàng, ngày giờ.
    * Giao dịch `REDEEM`: icon trừ đỏ `-300 điểm`, tên voucher đã đổi, ngày giờ.

### 7. Tích Hợp Real-time WebSocket
* Lắng nghe sự kiện `points_earned` từ `NotificationsGateway` (Port 3001).
* Khi nhận được thông báo:
  * Tự động làm mới số dư điểm của user và lịch sử giao dịch.
  * Hiển thị Dialog/SnackBar nổi chúc mừng: *"🎉 Bạn vừa nhận được [X] điểm từ [Tên Merchant]! Tổng điểm hiện tại: [Y]"*.
  * Nếu lên hạng (ví dụ từ Standard -> Silver), hiển thị hiệu ứng chúc mừng lên hạng đặc biệt.

---

## Proposed Changes

### Configuration & Core Layer

#### [MODIFY] [pubspec.yaml](file:///home/thien/TingTing/app_user/pubspec.yaml)
- Bổ sung các icon và package cần thiết nếu thiếu (hiện đã có `dio`, `flutter_riverpod`, `go_router`, `qr_flutter`, `socket_io_client`, `shared_preferences`).

#### [MODIFY] [api_client.dart](file:///home/thien/TingTing/app_user/lib/core/api_client.dart)
- Cập nhật class `ApiClient` hỗ trợ khởi tạo `Dio` instance có gắn tự động Header `Authorization: Bearer <token>` thông qua Interceptor, tự động bắt lỗi mạng 401 để xử lý đăng xuất.

#### [NEW] [constants.dart](file:///home/thien/TingTing/app_user/lib/core/constants.dart)
- Định nghĩa các hằng số dùng chung (Storage Keys, Membership Tier names, Points Ratio).

#### [NEW] [router.dart](file:///home/thien/TingTing/app_user/lib/core/router.dart)
- Thiết lập GoRouter quản lý toàn bộ luồng màn hình với Redirect Guard (chưa đăng nhập -> `/auth/phone`, đã đăng nhập -> `/home`).

---

### Data Models & State Providers

#### [NEW] [user_model.dart](file:///home/thien/TingTing/app_user/lib/models/user_model.dart)
- Model dữ liệu User khớp với Backend Entity: `id`, `phone_number`, `full_name`, `total_points`, `membership_tier`.

#### [NEW] [voucher_model.dart](file:///home/thien/TingTing/app_user/lib/models/voucher_model.dart)
- Model dữ liệu Voucher & Merchant: `id`, `title`, `description`, `points_cost`, `total_quantity`, `remaining_quantity`, `expired_at`, `merchant`.

#### [NEW] [user_voucher_model.dart](file:///home/thien/TingTing/app_user/lib/models/user_voucher_model.dart)
- Model Voucher cá nhân: `id`, `user_id`, `voucher_id`, `status` (ACTIVE, USED, EXPIRED), `redeemed_at`, nested `voucher`.

#### [NEW] [transaction_model.dart](file:///home/thien/TingTing/app_user/lib/models/transaction_model.dart)
- Model Lịch sử giao dịch: `id`, `type` (EARN, REDEEM), `points_delta`, `bill_amount`, `created_at`, nested `merchant`.

#### [NEW] [auth_provider.dart](file:///home/thien/TingTing/app_user/lib/providers/auth_provider.dart)
- StateNotifier quản lý trạng thái đăng nhập: `sendOtp()`, `verifyOtp()`, `logout()`, `checkAuthStatus()`.

#### [NEW] [user_provider.dart](file:///home/thien/TingTing/app_user/lib/providers/user_provider.dart)
- StateNotifier quản lý Profile người dùng, số dư điểm, và lịch sử giao dịch.

#### [NEW] [voucher_provider.dart](file:///home/thien/TingTing/app_user/lib/providers/voucher_provider.dart)
- Quản lý danh sách Voucher đang phát hành, phân loại theo category và tìm kiếm.

#### [NEW] [my_voucher_provider.dart](file:///home/thien/TingTing/app_user/lib/providers/my_voucher_provider.dart)
- Quản lý danh sách voucher đã đổi của user và thực hiện API đổi voucher (`redeemVoucher`).

---

### UI Components (Shared Widgets)

#### [MODIFY] [primary_button.dart](file:///home/thien/TingTing/app_user/lib/widgets/primary_button.dart)
- Thêm tham số `isLoading` để hiển thị `CircularProgressIndicator` màu trắng khi đang gọi API.

#### [MODIFY] [voucher_card.dart](file:///home/thien/TingTing/app_user/lib/widgets/voucher_card.dart)
- Tích hợp nhận trực tiếp `VoucherModel` hoặc `VoucherCardData`, hỗ trợ hiển thị tag "Mới", tag "Tặng".

#### [NEW] [ticket_notch_clipper.dart](file:///home/thien/TingTing/app_user/lib/widgets/ticket_notch_clipper.dart)
- Clipper tạo vết khoét bán nguyệt đối xứng ở 2 cạnh thân vé, đường cắt răng cưa / đứt đoạn giữa 2 phần voucher.

#### [NEW] [dynamic_qr_view.dart](file:///home/thien/TingTing/app_user/lib/widgets/dynamic_qr_view.dart)
- Hiển thị QR Code bằng thư viện `qr_flutter` với bộ đếm ngược 60 giây và hiệu ứng vòng tròn tiến trình.

#### [NEW] [banner_carousel.dart](file:///home/thien/TingTing/app_user/lib/widgets/banner_carousel.dart)
- Slider trình chiếu các banner quảng cáo chiến dịch hot ở trang chủ.

---

### Screens & Navigation Shell

#### [NEW] [main_shell.dart](file:///home/thien/TingTing/app_user/lib/screens/main_shell.dart)
- Khung điều hướng `BottomNavBar` tích hợp với `GoRouter StatefulShellRoute`.

#### [NEW] [phone_input_screen.dart](file:///home/thien/TingTing/app_user/lib/screens/auth/phone_input_screen.dart)
- Giao diện nhập số điện thoại chuẩn thiết kế.

#### [NEW] [otp_screen.dart](file:///home/thien/TingTing/app_user/lib/screens/auth/otp_screen.dart)
- Giao diện nhập 6 ô OTP, đếm ngược và xác thực token.

#### [NEW] [home_screen.dart](file:///home/thien/TingTing/app_user/lib/screens/home/home_screen.dart)
- Màn hình Home với đầy đủ các section: Header điểm, Banner, Quick Ticket, Hot deals.

#### [NEW] [earn_points_screen.dart](file:///home/thien/TingTing/app_user/lib/screens/earn/earn_points_screen.dart)
- Màn hình Dynamic QR định danh người dùng tự làm mới mỗi 60 giây để Merchant quét.

#### [NEW] [rewards_screen.dart](file:///home/thien/TingTing/app_user/lib/screens/rewards/rewards_screen.dart)
- Màn hình Đổi thưởng với tìm kiếm, danh mục, filter và danh sách voucher.

#### [NEW] [voucher_detail_screen.dart](file:///home/thien/TingTing/app_user/lib/screens/rewards/voucher_detail_screen.dart)
- Chi tiết voucher với hình ảnh, thẻ ticket notch, điều kiện sử dụng, nút đổi điểm.

#### [NEW] [my_vouchers_screen.dart](file:///home/thien/TingTing/app_user/lib/screens/my_vouchers/my_vouchers_screen.dart)
- Danh sách voucher đã đổi phân loại theo Đang có / Đã dùng / Hết hạn.

#### [NEW] [my_voucher_barcode_screen.dart](file:///home/thien/TingTing/app_user/lib/screens/my_vouchers/my_voucher_barcode_screen.dart)
- Màn hình hiển thị Barcode và mã định danh để đưa cho Merchant quét lúc thanh toán.

#### [NEW] [account_screen.dart](file:///home/thien/TingTing/app_user/lib/screens/account/account_screen.dart)
- Màn hình Hồ sơ & Tài khoản, liên kết mở Lịch sử và Đăng xuất.

#### [NEW] [transaction_history_screen.dart](file:///home/thien/TingTing/app_user/lib/screens/account/transaction_history_screen.dart)
- Màn hình Lịch sử tích / đổi điểm chi tiết.

#### [MODIFY] [main.dart](file:///home/thien/TingTing/app_user/lib/main.dart)
- Chuyển `main.dart` thành entry point chính thức bọc bởi `ProviderScope` của Riverpod, chạy `router` và gắn listener lắng nghe sự kiện WebSocket toàn app.

---

## Verification Plan

### Automated Tests
1. **Kiểm tra biên dịch và cú pháp Dart:**
   ```bash
   cd app_user && flutter analyze
   ```
2. **Kiểm tra unit test / widget test cơ sở:**
   ```bash
   cd app_user && flutter test
   ```

### Manual Verification
1. **Chạy Backend & Seed dữ liệu:**
   - Đảm bảo Backend chạy trên port 3000 và có seed data: `cd backend && npm run seed && npm run start:dev`.
2. **Test luồng Đăng nhập (Auth Flow):**
   - Mở User App -> Nhập SĐT `0900000001` -> Nhấn "Tiếp tục".
   - Màn hình OTP xuất hiện -> Nhập `000000` -> Xác thực thành công -> Vào Trang chủ.
3. **Test Trang chủ & Số dư điểm:**
   - Kiểm tra số dư điểm và tên hiển thị chính xác theo User trong seed data.
4. **Test Tab Tích điểm (Dynamic QR):**
   - Chuyển sang Tab "Tích điểm" -> Kiểm tra mã QR hiển thị rõ ràng, timer 60s đếm ngược mượt mà.
5. **Test Tab Đổi thưởng & Màn hình chi tiết:**
   - Xem danh sách voucher -> Bấm vào 1 voucher -> Kiểm tra giao diện Ticket Notch cắt 2 bên -> Nhấn "Đổi ngay" -> Trừ điểm và voucher xuất hiện trong "Ưu đãi của bạn".
6. **Test Xem Barcode Voucher:**
   - Mở voucher đã đổi -> Màn hình Barcode hiển thị mã vạch và ID rõ ràng.
7. **Test Real-time WebSocket:**
   - Đang mở User App -> Gọi API `POST /points/earn` từ Postman hoặc curl -> App nhận thông báo SnackBar/Popup cộng điểm ngay lập tức và tự cập nhật số dư điểm mới.
