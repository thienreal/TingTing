# Hướng Dẫn Sử Dụng Dự Án - Dành Cho Lập Trình Viên

> Tài liệu này dành cho các thành viên trong nhóm dev. Đọc kỹ trước khi bắt đầu viết code.
> Để cài đặt môi trường lần đầu, đọc `docs/SETUP.md` trước.

---

## Mục Lục

1. [Tổng quan dự án & Tech Stack](#1-tổng-quan-dự-án--tech-stack)
2. [Các Công Cụ Cần Thiết](#2-các-công-cụ-cần-thiết)
3. [Cấu hình nghiệp vụ linh hoạt (Config-Driven)](#3-cấu-hình-nghiệp-vụ-linh-hoạt)
4. [Vị trí các file quan trọng](#4-vị-trí-các-file-quan-trọng)
5. [Biến môi trường (.env)](#5-biến-môi-trường-env)
6. [Các lệnh CLI thường dùng](#6-các-lệnh-cli-thường-dùng)
7. [Quản lý Database (TypeORM Migration)](#7-quản-lý-database-typeorm-migration)

---

## 1. Tổng Quan Dự Án & Tech Stack

- **Tên dự án:** TingTing - Nền Tảng Tích Hợp Ví Điểm Thưởng Tập Trung.
- **Mô hình:** SaaS B2B2C.
- **Mục tiêu MVP:** Đưa toàn bộ thẻ thành viên, điểm thưởng, voucher của nhiều cửa hàng khác nhau vào một nền tảng duy nhất.

| Thành phần | Công nghệ | Ghi chú |
|---|---|---|
| Backend Framework | NestJS (TypeScript) | Module - Controller - Service |
| ORM | TypeORM | Không dùng Prisma |
| Database | PostgreSQL >= 15 | Duy nhất, toàn bộ hệ thống |
| Xác thực | JWT + OTP (số điện thoại) | User dùng Mock OTP (000000) MVP, Merchant dùng email/password |
| Real-time | WebSocket (Socket.IO) | Chỉ hoạt động khi app đang mở |
| Mobile | Flutter (Dart) | Dùng chung cho User App và Merchant App |
| State Management | Riverpod | Flutter |
| HTTP Client | Dio | Flutter |
| Navigation | go_router | Flutter |

---

## 2. Các Công Cụ Cần Thiết

Để phát triển dự án này, bạn cần đảm bảo đã cài đặt các công cụ sau (xem chi tiết cách cài đặt tại `SETUP.md`):

- **Node.js (>= 20.x LTS)** & **npm (>= 10.x)**: Chạy backend (NestJS).
- **Docker & Docker Compose**: Dùng để chạy database PostgreSQL + pgAdmin nhanh chóng mà không cần cài đặt service cục bộ.
- **Flutter SDK (>= 3.x)**: Framework để phát triển Mobile App cho User và Merchant.
- **NestJS CLI (>= 10.x)**: Hỗ trợ sinh (generate) code module, controller, service (`npm i -g @nestjs/cli`).
- **Git**: Quản lý phiên bản mã nguồn.
- **IDE (Khuyên dùng)**: 
  - **VS Code**: Nên cài đặt các extension như *ESLint, Prettier, Flutter, Dart, Docker*.
  - **Android Studio / Xcode**: Dành cho việc cấu hình và chạy máy ảo Android/iOS cũng như build release.

---

## 3. Cấu hình Nghiệp vụ Linh hoạt (Config-Driven)

Dự án đề cao tính linh hoạt. Các tham số nghiệp vụ quan trọng không bị hardcode mà được đưa ra file cấu hình `.env` hoặc file `config`.

- **Tỷ lệ Tích điểm (Points Ratio):** Cấu hình linh hoạt. Ví dụ MVP: `10,000 VND = 1 Điểm`. Hệ thống có khả năng mở rộng để ghi đè tỷ lệ này theo từng Merchant.
- **Hạng Thành viên (Membership Tiers):** Tên hạng, hạn mức điểm được cấu hình ngoài.
  - `STANDARD`: Từ 0 - 499 điểm.
  - `SILVER`: Từ 500 - 1,499 điểm.
  - `GOLD`: Từ 1,500 điểm trở lên.
- **Hạn mức & Cấu hình Voucher:**
  - Hạn mức đổi Voucher (Số điểm cần thiết, số lượng tồn kho) hoàn toàn do **Merchant quyết định**. 
  - Giao diện `app_merchant` có tính năng cho chủ cửa hàng trực tiếp nhập/cấu hình thông số "Điểm tối thiểu/Giá voucher" khi tạo Deal mới.

---

## 4. Vị Trí Các File Quan Trọng

| File | Đường dẫn | Mục đích |
|---|---|---|
| Biến môi trường (thực tế) | `backend/.env` | Cấu hình kết nối, secret key. **Không commit lên Git** |
| Biến môi trường (mẫu) | `backend/.env.example` | File mẫu để hướng dẫn. An toàn để commit |
| Cấu hình TypeORM | `backend/src/config/database.config.ts` | Kết nối DB, cấu hình migration CLI |
| Dependencies Backend | `backend/package.json` | Toàn bộ thư viện Node.js, npm scripts |
| Docker Compose | `docker-compose.yml` | Khởi động PostgreSQL + pgAdmin bằng Docker |
| SQL khởi tạo DB | `docker/init.sql` | Script chạy 1 lần khi tạo container PostgreSQL |
| Theme Flutter (User) | `app_user/lib/core/theme.dart` | Màu sắc, font. Bắt buộc dùng thay vì hardcode |
| Theme Flutter (Merchant) | `app_merchant/lib/core/theme.dart` | Tương tự |
| API Client (User) | `app_user/lib/core/api_client.dart` | Base URL kết nối tới Backend |
| API Client (Merchant) | `app_merchant/lib/core/api_client.dart` | Tương tự |
| Quy tắc UI/UX | `docs/UI_Design_Rules.md` | Thông số màu, font, border radius chính xác |
| Theo dõi task | `docs/task_tracker.md` | Cập nhật khi hoàn thành một task |

---

## 5. Biến Môi Trường (.env)

File `backend/.env` — **không bao giờ được commit lên GitHub.**
Khi mới clone dự án, chạy `cp backend/.env.example backend/.env` rồi điền thông tin.

### Bảng giải thích toàn bộ biến

| Biến | Ví dụ | Giải thích |
|---|---|---|
| `PORT` | `3000` | Cổng chạy Backend REST API |
| `WEBSOCKET_PORT` | `3001` | Cổng chạy WebSocket server |
| `DATABASE_URL` | `postgresql://...` | Chuỗi kết nối đầy đủ tới PostgreSQL |
| `DB_HOST` | `localhost` | Địa chỉ máy chủ PostgreSQL |
| `DB_PORT` | `5432` | Cổng PostgreSQL (mặc định 5432) |
| `DB_USERNAME` | `postgres` | Tên tài khoản PostgreSQL |
| `DB_PASSWORD` | `123456` | Mật khẩu PostgreSQL |
| `DB_NAME` | `tingting_db` | Tên database |
| `TYPEORM_SYNC` | `true` | `true`: TypeORM tự tạo bảng (DEV only). `false`: Dùng Migration (Production) |
| `TYPEORM_LOGGING` | `true` | `true`: In câu SQL ra terminal để debug |
| `JWT_SECRET` | `abc...xyz` | Khóa bí mật ký JWT. Phải thay đổi khi deploy Production |
| `JWT_EXPIRES_IN` | `7d` | Thời hạn JWT. `7d` = 7 ngày, `24h` = 24 giờ |
| `OTP_EXPIRY_SECONDS` | `300` | Thời gian hiệu lực OTP (giây). `300` = 5 phút |
| `POINTS_RATIO` | `10000` | Tỷ lệ quy đổi: 10,000 VND = 1 Điểm |
| `MEMBERSHIP_TIERS_CONFIG` | `{"STANDARD":0,...}` | Cấu hình các hạng thành viên |
| `WEBSOCKET_PORT` | `3001` | Cổng cho kết nối Real-time WebSocket |

> **Cảnh báo Production:** Đặt `TYPEORM_SYNC=false` và `TYPEORM_LOGGING=false`. Đổi `JWT_SECRET` thành chuỗi ngẫu nhiên.

---

## 6. Các Lệnh CLI Thường Dùng

### Backend (NestJS) — chạy trong thư mục `backend/`

```bash
# Cài thư viện (lần đầu hoặc sau khi pull code mới)
npm install

# Chạy server ở chế độ dev (tự reload khi sửa code)
npm run start:dev

# Chạy server ở chế độ production (build trước)
npm run build
npm run start:prod

# Chạy unit test
npm run test

# Chạy test với coverage report
npm run test:cov

# Kiểm tra lỗi TypeScript + ESLint
npm run lint

# Tự động sửa lỗi lint
npm run lint -- --fix
```

### Docker — chạy trong thư mục gốc `TingTing/`

> Yêu cầu: Đã cài Docker Desktop.

```bash
# Khởi động PostgreSQL + pgAdmin (chạy ngầm)
docker-compose up -d

# Xem log realtime của tất cả service
docker-compose logs -f

# Dừng tất cả container (giữ nguyên dữ liệu)
docker-compose down

# Dừng VÀ XÓA SẠCH dữ liệu
docker-compose down -v

# Truy cập trực tiếp vào PostgreSQL
docker exec -it tingting_postgres psql -U postgres -d tingting_db
```

### TypeORM Migration — chạy trong thư mục `backend/`

```bash
# Tạo file migration mới (thay "TenMigration" bằng tên)
npx typeorm migration:generate src/migrations/TenMigration -d src/config/database.config.ts

# Chạy tất cả migration chưa được áp dụng
npx typeorm migration:run -d src/config/database.config.ts

# Hoàn tác migration gần nhất
npx typeorm migration:revert -d src/config/database.config.ts
```

### NestJS CLI

```bash
# Tạo module mới (vd: users)
nest generate module modules/users

# Tạo controller mới
nest generate controller modules/users

# Tạo service mới
nest generate service modules/users
```

### Flutter — chạy trong thư mục `app_user/` hoặc `app_merchant/`

```bash
# Tải/cập nhật thư viện
flutter pub get

# Chạy app trên thiết bị/emulator
flutter run

# Build APK cho Android
flutter build apk
```

---

## 7. Quản Lý Database (TypeORM Migration)

### Khi nào dùng Migration thay vì TYPEORM_SYNC?
- **TYPEORM_SYNC=true (DEV):** Tự động cập nhật bảng. Tiện lợi nhưng nguy hiểm với dữ liệu thực.
- **Migration (Production):** Kiểm soát chính xác từng thay đổi, an toàn.

### Quy trình làm việc với Migration
1. Sửa Entity TypeScript.
2. Tạo Migration: `npx typeorm migration:generate ...`
3. Kiểm tra file migration trong `src/migrations/`.
4. Chạy Migration: `npx typeorm migration:run ...`
