# 📋 TingTing Project - Task Tracker

> Bảng theo dõi tiến độ công việc dự án "Nền Tảng Tích Hợp Ví Điểm Thưởng Tập Trung".
> Định dạng bám sát vào lộ trình (Roadmap) và cấu trúc kiến trúc (Architecture) của dự án.
>
> Quy ước đánh dấu:
> - `[ ]` Chưa bắt đầu (To do)
> - `[/]` Đang thực hiện (In progress)
> - `[x]` Đã hoàn thành (Done)

---

## Giai Đoạn 1: Phát triển MVP & Tính năng Cốt lõi (0 - 6 tháng)

---

### 1.1 Khởi tạo dự án & Cấu hình môi trường

- [x] Khởi tạo Git repository với file `.gitignore` (loại trừ `.env`, `node_modules/`, `build/`).
- [x] Tạo cấu trúc thư mục Monorepo (`backend/`, `app_user/`, `app_merchant/`).

**Backend (Node.js/NestJS):**
- [x] Khởi tạo dự án NestJS bằng lệnh `nest new backend`.
- [x] Cài đặt và cấu hình ESLint + Prettier cho TypeScript.
- [x] Tạo file `backend/config/business.config.ts` hoặc `.env.example` chứa các tham số: `DATABASE_URL`, `JWT_SECRET`, `FCM_SERVER_KEY`, `POINTS_RATIO` (Tỉ lệ đổi tiền -> điểm), `MEMBERSHIP_TIERS_CONFIG` (Cấu hình hạn mức lên hạng).
- [x] Tạo file `backend/.env` điền giá trị thực tế (chạy Local, không đẩy lên Git).
- [x] Cài đặt TypeORM và kết nối PostgreSQL thông qua biến `DATABASE_URL`.

**Database (PostgreSQL):**
- [x] Cài đặt PostgreSQL và tạo database `tingting_db`.
- [x] Kích hoạt extension `uuid-ossp`.

**Frontend (User & Merchant App - Flutter):**
- [x] Khởi tạo 2 dự án Flutter `app_user` và `app_merchant`.
- [x] Thêm thư viện: `dio`, `flutter_riverpod`, `go_router`, `mobile_scanner`, `qr_flutter` (chỉ user), `shared_preferences`.
- [x] Tạo file `theme.dart` (màu Vàng, Hồng theo UI_Design_Rules) và `api_client.dart` (chỉ IP Local LAN) cho cả 2 app.

---

### 1.2 Thiết kế Database Schema & Seed Data

- [x] Tạo Entity `Users`: `id`, `phone_number`, `full_name`, `total_points`, `membership_tier`, `created_at`.
- [x] Tạo Entity `Merchants`: `id`, `name`, `category`, `qr_static_code`, `is_active`, `created_at`.
- [x] Tạo Entity `Transactions`: `id`, `user_id`, `merchant_id`, `type`, `points_delta`, `bill_amount`, `created_at`.
- [x] Tạo Entity `Vouchers`: `id`, `merchant_id`, `title`, `description`, `points_cost`, `total_quantity`, `remaining_quantity`, `expired_at`.
- [x] Tạo Entity `UserVouchers`: `id`, `user_id`, `voucher_id`, `status` (ACTIVE, USED, EXPIRED), `redeemed_at`.
- [x] Viết TypeORM migration tạo bảng.
- [x] **Viết script seed data:** Sinh ra ~10 Merchant mẫu thực tế, 20 User, 30 Voucher đa dạng mức điểm, 50 Transaction (Phục vụ Demo).

---

### 1.3 Thiết kế UI/UX (Wireframe & Component cơ sở)

- [ ] `app_user`: Xây dựng `PrimaryButton`, `VoucherCard` (bo góc 16px), `BottomNavBar` (4 tab).
- [ ] `app_merchant`: Xây dựng `ActionButton`, `TransactionTile`.

---

### 1.4 Phát triển Backend API Cốt lõi

**Module: Auth**
- [ ] API `POST /auth/send-otp`: Nhận `phone_number`, sinh Mock OTP (cố định là `000000` cho MVP).
- [ ] API `POST /auth/verify-otp`: Kiểm tra OTP giả lập, trả về JWT Access Token.
- [ ] API `POST /auth/merchant/login`: Đăng nhập Merchant (email/password).
- [ ] Thiết lập RBAC (Role-Based Access Control).

**Module: Users & Points**
- [ ] API `GET /users/me` và `GET /users/me/transactions`.
- [ ] API `POST /points/earn` (Merchant only): Cộng điểm theo `POINTS_RATIO` (đọc từ config), cập nhật `membership_tier` nếu vượt ngưỡng, dùng **Row-Level Lock** trên table Users.
- [ ] API `GET /points/balance`.

**Module: Vouchers**
- [ ] API `GET /vouchers` và `GET /vouchers/:id`.
- [ ] API `POST /vouchers/:id/redeem` (User only): Dùng **PostgreSQL Transaction + Row-Level Lock** chống double-spending (Kiểm tra điểm đủ -> Giảm tồn kho -> Trừ điểm -> Tạo UserVoucher).
- [ ] API `GET /vouchers/mine`: Trả danh sách voucher của user.
- [ ] API `POST /merchants/vouchers` (Merchant only): Tạo Voucher mới (truyền tham số `points_cost` để thiết lập hạng mức đổi).
- [ ] API `POST /points/use-voucher` (Merchant only): Quét barcode voucher để chuyển trạng thái `USED`.

**Module: Merchants (Báo cáo)**
- [ ] API `GET /merchants/me/report`: Thống kê giao dịch, voucher.

---

### 1.5 Tích hợp WebSocket (Real-time Notification)

- [ ] Cài đặt `socket.io` trong backend, cấu hình `WEBSOCKET_PORT` (nếu cần).
- [ ] Tích hợp phát sự kiện (emit) qua WebSocket khi gọi `POST /points/earn` thành công (Báo User có điểm).
- [ ] Flutter `app_user`: Kết nối WebSocket, lắng nghe sự kiện để hiển thị thông báo.

---

### 1.6 Phát triển Mobile App - User App

- [ ] **Auth:** Nhập sđt -> Nhập OTP (`000000`) -> Đăng nhập.
- [ ] **Home:** Xem điểm, banner quảng cáo.
- [ ] **Earn:** QR Code định danh động, làm mới mỗi 60 giây.
- [ ] **Rewards:** Danh sách Voucher, chi tiết, nút "Đổi ngay".
- [ ] **My Vouchers:** Voucher đang có, hiển thị barcode để cửa hàng quét. *(Đã bỏ tính năng Tặng Voucher)*

---

### 1.7 Phát triển Mobile App - Merchant App

- [ ] **Auth:** Đăng nhập Email/Password.
- [ ] **Scan QR:** Quét mã User để cộng điểm (nhập số tiền hóa đơn) HOẶC quét Voucher để xác nhận áp dụng.
- [ ] **Create Deal:** Form tạo Voucher, cho phép Merchant tự **nhập hạn mức điểm cần để đổi (points_cost)**, số lượng phát hành.
- [ ] **Report:** Thống kê CRM cơ bản.

---

### 1.8 Kiểm thử (Testing & Validation)

- [ ] Viết unit test chống double-spending cho `redeem`.
- [ ] Test luồng thủ công trên Postman (đã có script Seed).
- [ ] Cài đặt 2 app lên máy thật/máy ảo cùng mạng LAN, test quét QR thực tế qua Camera.
