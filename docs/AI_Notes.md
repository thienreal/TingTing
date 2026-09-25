# Nhật Ký Công Việc Của AI (AI Notes)

> File này dùng để lưu trữ toàn bộ lịch sử chỉnh sửa, thay đổi kế hoạch, mã nguồn, kiến trúc và các luồng nghiệp vụ do AI thực hiện. Bất cứ hành động thay đổi nào cũng phải được ghi lại tại đây theo đúng định dạng được quy định trong `agent.md`.

---

### [2026-09-25 09:05:00] Hoàn thành Task 1.4 — Module Merchants (Báo cáo)

- **Task:** 1.4 — Phát triển Backend API Cốt lõi — Module Merchants
- **Các công việc đã thực hiện:**
  1. Tạo `merchants/merchants.service.ts`: method `getReport(merchantId)` kết nối đến repository của `Transaction`, `Voucher`, `UserVoucher` để thống kê: `active_vouchers_count`, `total_points_issued` (loại EARN), `total_transactions`, và `used_vouchers_count`.
  2. Tạo `merchants/merchants.controller.ts`: định tuyến `GET /merchants/me/report`, sử dụng `JwtAuthGuard` và role `MERCHANT`.
  3. Tạo `merchants/merchants.module.ts`: cấu hình `TypeOrmModule` và `AuthModule`, export `MerchantsService`.
  4. Đăng ký `MerchantsModule` vào `app.module.ts`.
  5. Cập nhật `docs/task_tracker.md` đánh dấu hoàn tất toàn bộ Task 1.4.
  6. Chạy `npm run build` thành công, không lỗi.
- **Lý do:** Hoàn thành chặng 4, cũng là chặng cuối của Task 1.4 (Phát triển Backend API Cốt lõi).
- **Thông số kỹ thuật:**
  - Logic tính tổng bằng QueryBuilder cho `total_points_issued` (SUM `points_delta`) và count join bảng cho `used_vouchers_count`.

---

### [2026-09-25 08:49:00] Hoàn thành Task 1.4 — Module Vouchers


- **Task:** 1.4 — Phát triển Backend API Cốt lõi — Module Vouchers
- **Các công việc đã thực hiện:**
  1. Tạo `vouchers/dto/create-voucher.dto.ts`: Validate title, description (optional), points_cost, total_quantity, expired_at (ISO 8601).
  2. Tạo `vouchers/dto/use-voucher.dto.ts`: Validate user_voucher_id UUID.
  3. Tạo `vouchers/vouchers.service.ts` với 5 methods:
     - `findAll()`: Query voucher `remaining_quantity > 0`, kèm relation merchant, sort `points_cost ASC`.
     - `findOne(id)`: Tìm theo UUID, throw 404 nếu không có.
     - `findMyVouchers(userId)`: Query UserVoucher kèm `voucher.merchant`, sort `created_at DESC`.
     - `createVoucher(merchantId, dto)`: Xác thực merchant active, khởi tạo `remaining_quantity = total_quantity`.
     - `redeemVoucher(voucherId, userId)`: **Double Row-Level Lock** — Lock Voucher + Lock User đồng thời trong 1 QueryRunner Transaction. Kiểm tra: còn hạn → còn tồn kho → chưa đổi → đủ điểm → Giảm `remaining_quantity` → Trừ `total_points` → Tạo `UserVoucher(ACTIVE)` → COMMIT. Rollback khi lỗi.
     - `useVoucher(merchantId, dto)`: Tìm UserVoucher, kiểm tra **ownership** (`voucher.merchant_id === merchantId`), kiểm tra status ACTIVE, kiểm tra `expired_at`, chuyển ACTIVE → USED.
  4. Tạo `vouchers/vouchers.controller.ts`: 6 endpoints. `GET /vouchers/mine` khai báo **TRƯỚC** `GET /vouchers/:id` để tránh "mine" bị parse thành UUID param. `ParseUUIDPipe` validate tự động param `:id`.
  5. Tạo `vouchers/vouchers.module.ts`: Import `AuthModule`, 4 entities.
  6. Cập nhật `app.module.ts`: Import `VouchersModule`.
  7. Cập nhật `docs/task_tracker.md`: Tick `[x]` 5 tasks Vouchers.
  8. Chạy `npm run build` → Exit code 0, không có lỗi TypeScript.
- **Lý do:** Hoàn thành chặng 3 của Task 1.4 (Vouchers API — module phức tạp nhất).
- **Thông số kỹ thuật:**
  - Double-spending protection: 2 `SELECT FOR UPDATE` trong cùng 1 `QueryRunner` transaction — Voucher lock trước, User lock sau.
  - Ownership check trong `useVoucher`: so sánh `userVoucher.voucher.merchant_id !== merchantId` → throw 403.
  - Route order: `/vouchers/mine` phải đặt trước `/vouchers/:id` trong NestJS để tránh xung đột routing.
  - `MoreThan(0)` từ TypeORM dùng cho filter `remaining_quantity > 0`.
  - Cấu trúc: `backend/src/modules/vouchers/{dto/,entities/,vouchers.service.ts,vouchers.controller.ts,vouchers.module.ts}`.

---

### [2026-09-25 08:40:00] Hoàn thành Task 1.4 — Module Users & Points


- **Task:** 1.4 — Phát triển Backend API Cốt lõi — Module Users & Points
- **Các công việc đã thực hiện:**
  1. Tạo `users/dto/earn-points.dto.ts`: Validate `user_id` (UUID v4) + `bill_amount` (số dương, tối thiểu 1.000đ).
  2. Tạo `users/users.service.ts` với 4 methods:
     - `getMe()`: Tìm user theo userId từ JWT, throw 404 nếu không có.
     - `getMyTransactions()`: Query lịch sử transaction kèm relation `merchant`, ORDER BY `created_at DESC`.
     - `getPointsBalance()`: Trả `total_points` và `membership_tier`, chỉ SELECT 2 cột cần thiết.
     - `earnPoints()`: **Row-Level Lock** (`SELECT FOR UPDATE` qua TypeORM `pessimistic_write`). Tính điểm = `floor(bill_amount / POINTS_RATIO)`. Tự động tính lại `membership_tier` bằng so sánh ngưỡng từ `MEMBERSHIP_TIERS_CONFIG` (parse JSON từ .env). Lưu Transaction record. Rollback nếu lỗi, luôn release QueryRunner.
  3. Tạo `users/users.controller.ts`: 4 endpoints với RBAC đúng role (USER/MERCHANT), `@CurrentUser()` decorator.
  4. Tạo `users/users.module.ts`: Import `AuthModule` (dùng guards), `TypeOrmModule.forFeature([User, Transaction, Merchant])`.
  5. Cập nhật `app.module.ts`: Import `UsersModule`.
  6. Cập nhật `docs/task_tracker.md`: Tick `[x]` 3 tasks Users & Points.
  7. Chạy `npm run build` → Exit code 0, không có lỗi TypeScript.
- **Lý do:** Hoàn thành chặng 2 của Task 1.4 (Users & Points API).
- **Thông số kỹ thuật:**
  - `POINTS_RATIO`: đọc từ `.env` (hiện = 1000 → 1.000đ = 1 điểm), parse `parseInt`.
  - `MEMBERSHIP_TIERS_CONFIG`: JSON string từ `.env` → parse → sort giảm dần → so sánh từ tier cao nhất.
  - Row-Level Lock: `queryRunner.manager.findOne(User, { lock: { mode: 'pessimistic_write' } })`.
  - QueryRunner: `createQueryRunner()` → `connect()` → `startTransaction()` → `commitTransaction()` / `rollbackTransaction()` → `release()`.
  - Cấu trúc: `backend/src/modules/users/{dto/,entities/,users.service.ts,users.controller.ts,users.module.ts}`.

---

### [2026-09-25 08:17:00] Hoàn thành Task 1.4 — Module Auth (RBAC, OTP, JWT)


- **Task:** 1.4 — Phát triển Backend API Cốt lõi — Module Auth
- **Các công việc đã thực hiện:**
  1. Tạo `auth/dto/send-otp.dto.ts`: Validate số điện thoại VN (regex `0[3|5|7|8|9]xxxxxxxx`).
  2. Tạo `auth/dto/verify-otp.dto.ts`: Validate phone + OTP 6 chữ số. Comment `@mvp` và `@future` rõ ràng chỉ tới `Future_Development.md §1`.
  3. Tạo `auth/dto/merchant-login.dto.ts`: Validate email + password minLength 6.
  4. Tạo `auth/strategies/jwt.strategy.ts`: Passport JWT Strategy, đọc `JWT_SECRET` từ ConfigService (không hardcode). Export interface `JwtPayload`.
  5. Tạo `auth/guards/jwt-auth.guard.ts`: Wrapper mỏng trên `AuthGuard('jwt')`.
  6. Tạo `auth/guards/roles.guard.ts`: Đọc metadata `ROLES_KEY`, so sánh `req.user.role`, throw `ForbiddenException` 403 nếu không đủ quyền.
  7. Tạo `auth/decorators/roles.decorator.ts`: `@Roles('USER' | 'MERCHANT')` dùng `SetMetadata`.
  8. Tạo `auth/decorators/current-user.decorator.ts`: `@CurrentUser()` extract `req.user` từ param.
  9. Tạo `auth/auth.service.ts`: 3 methods: `sendOtp` (Mock OTP `000000` + log WARN + comment @future chi tiết), `verifyOtp` (kiểm tra mock + auto-register User + ký JWT), `merchantLogin` (bcrypt so sánh hash + ký JWT). Hằng số `MOCK_OTP_CODE` được đặt riêng và có comment đầy đủ.
  10. Tạo `auth/auth.controller.ts`: 3 POST endpoints, `@HttpCode(200)`.
  11. Tạo `auth/auth.module.ts`: `JwtModule.registerAsync` đọc secret từ ConfigService, export guards cho các module khác.
  12. Cập nhật `app.module.ts`: Import `AuthModule`.
  13. Cập nhật `main.ts`: Bật `ValidationPipe` global (`whitelist: true`, `forbidNonWhitelisted: true`, `transform: true`).
  14. Cập nhật `docs/Future_Development.md §1`: Bổ sung sub-list 5 điểm chi tiết về vị trí chính xác trong code cần sửa khi tích hợp SMS OTP thật.
  15. Cập nhật `docs/task_tracker.md`: Tick `[x]` 4 tasks Auth.
  16. Chạy `npm run build` → Exit code 0, không có lỗi TypeScript.
- **Lý do:** Hoàn thành chặng 1 của Task 1.4 theo kế hoạch chia nhỏ đã thảo luận.
- **Thông số kỹ thuật:**
  - Mock OTP: hằng số `MOCK_OTP_CODE = '000000'` trong `auth.service.ts`, lưu trong `Map<string, string>` in-memory.
  - JWT payload: `{ sub: uuid, role: 'USER'|'MERCHANT', phone?: string, email?: string }`.
  - JWT secret/expiry: đọc từ `JWT_SECRET`, `JWT_EXPIRES_IN` trong `.env` (hiện: `tingting_dev_secret_key_2026`, `7d`).
  - Password hash: bcrypt (so sánh với `merchant.password` đã hash sẵn trong seed).
  - RBAC: `@Roles('MERCHANT') + @UseGuards(JwtAuthGuard, RolesGuard)` pattern.
  - Cấu trúc: `backend/src/modules/auth/{dto,strategies,guards,decorators}/`.

---

### [2026-09-25 08:02:00] Hoàn thành Task 1.3 — Xây dựng UI Components cơ sở


- **Task:** 1.3 — Thiết kế UI/UX (Wireframe & Component cơ sở)
- **Các công việc đã thực hiện:**
  1. Đọc và phân tích `agent.md`, `docs/UI_Design_Rules.md`, `docs/CODE_STANDARDS.md`, `docs/CROSS_CHECK.md`.
  2. Xem các ảnh thiết kế mẫu trong `anh/` để nắm phong cách Vàng/Hồng, card bo góc, BottomNavBar 4 tab.
  3. Tạo `app_user/lib/widgets/primary_button.dart`: Nút CTA màu Hồng (#E8687D), bo góc 12px, full-width, hỗ trợ prefixIcon và trạng thái disabled.
  4. Tạo `app_user/lib/widgets/voucher_card.dart`: Card trắng bo góc 16px, shadow 0.05 opacity, thumbnail (network/placeholder gradient), merchant name, title, points badge icon đồng xu vàng. Kèm data class `VoucherCardData`.
  5. Tạo `app_user/lib/widgets/bottom_nav_bar.dart`: BottomNavBar 4 tab (Trang chủ, Tích điểm, Đổi thưởng, Tài khoản). Active: icon filled + text bold #1A1A1A. Inactive: icon outline + text #757575. Enum `AppTab`.
  6. Tạo `app_merchant/lib/widgets/action_button.dart`: Nút Merchant màu Vàng (#FAD240) variant `filled`, viền Hồng (#E8687D) variant `outlined`. Enum `ActionButtonVariant`.
  7. Tạo `app_merchant/lib/widgets/transaction_tile.dart`: Tile giao dịch, icon phân loại, delta điểm xanh lá (+) / đỏ san hô (-), format giờ phút & VND. Data class `TransactionTileData`, enum `TransactionType`.
  8. Cập nhật `docs/task_tracker.md`: tick [x] cho toàn bộ task 1.3.
- **Lý do:** Task 1.3 yêu cầu xây dựng component UI cơ sở trước khi phát triển màn hình hoàn chỉnh ở task 1.6 và 1.7.
- **Thông số kỹ thuật:**
  - Màu sắc: tất cả từ `AppColors` (theme.dart), không hardcode.
  - Radius: Card 16px, Button & Tile 12px.
  - BoxShadow: `Colors.black.withOpacity(0.05)`, blurRadius 10, offset (0,4).
  - Font: Bold 700 (tiêu đề), SemiBold 600 (nút), Regular 400 (body).
  - Thư mục mới: `app_user/lib/widgets/`, `app_merchant/lib/widgets/`.
  - Header DartDoc đầy đủ theo chuẩn `CODE_STANDARDS.md`.

---

### [2026-08-29 21:33:00] Khởi tạo tài liệu quy tắc và hệ thống lưu vết

- **Các công việc đã thực hiện:** 
  1. Tạo file `agent.md` để quy định phong cách thiết kế UI/UX dựa trên app mẫu.
  2. Tạo file `AI_Notes.md` để ghi nhận toàn bộ lịch sử làm việc của AI.
  3. Cập nhật `agent.md` để ép buộc mọi agent sau này phải ghi log vào `AI_Notes.md` mỗi khi có thay đổi.
- **Lý do:** Người dùng yêu cầu phải có một cơ chế giám sát và lưu lại mọi thay đổi do AI thực hiện để dễ dàng theo dõi tiến độ, mã nguồn và các quyết định kiến trúc.
- **Mục đích:** Đảm bảo tính minh bạch trong quá trình AI hỗ trợ code và thiết kế; tránh việc AI tự ý thay đổi code/luồng thực hiện mà không báo trước hoặc không rõ nguyên nhân.
- **Lợi ích:** Giúp chủ dự án (người dùng) luôn nắm bắt được trạng thái dự án. Thuận tiện cho việc review code, debug, và quay lại (rollback) các thay đổi nếu cần thiết. Đảm bảo mọi AI Agent kế nhiệm đều hiểu bối cảnh và lịch sử dự án.

---

### [2026-08-29 21:34:00] Cập nhật quy tắc thiết kế UI/UX chuyên sâu
- **Các công việc đã thực hiện:** 
  1. Phân tích lại toàn bộ các ảnh mẫu trong thư mục `anh/` bằng thị giác máy tính.
  2. Thay thế Mục 2 trong file `agent.md` bằng các thông số kỹ thuật chính xác 100% bao gồm: Mã màu Hex (Vàng `#FAD240`, Hồng/Đỏ `#E8687D`, Xám nền `#F4F5F6`), thông số Border Radius (12px, 16px), BoxShadow, và các quy chuẩn Typography cụ thể.
- **Lý do:** Người dùng yêu cầu quy tắc thiết kế phải chính xác 100% và y chang với style trong thư mục ảnh, không được mô tả chung chung.
- **Mục đích:** Khóa chặt hệ quy chiếu về giao diện để khi AI (hoặc các Subagent) tiến hành viết code Flutter, các thông số về màu sắc, khoảng cách, và hiệu ứng sẽ hoàn toàn đồng nhất ngay từ những dòng code đầu tiên.
- **Lợi ích:** Tránh việc AI tự sáng tạo ra các màu sắc hay kích thước không đồng bộ, giảm thiểu tối đa thời gian phải review và chỉnh sửa lại giao diện (UI) cho lập trình viên.

---

### [2026-08-29 21:36:00] Chuyển đổi đường dẫn tuyệt đối sang tương đối
- **Các công việc đã thực hiện:** 
  1. Cập nhật file `agent.md`: Đổi `/home/thien/TingTing/anh/` thành `./anh/`.
  2. Cập nhật file `agent.md`: Đổi `/home/thien/TingTing/AI_Notes.md` thành `./AI_Notes.md`.
- **Lý do:** Người dùng yêu cầu không sử dụng đường dẫn tuyệt đối.
- **Mục đích:** Giúp các file cấu hình và tài liệu hướng dẫn linh hoạt hơn. Không bị lỗi đường dẫn khi dự án được copy/clone sang một thư mục máy tính khác hoặc đẩy lên GitHub.
- **Lợi ích:** Tăng tính di động (portability) của dự án, tránh các lỗi môi trường không cần thiết cho lập trình viên trong tương lai.

---

### [2026-08-29 21:38:00] Quy hoạch tài liệu vào thư mục /docs và tách quy tắc UI
- **Các công việc đã thực hiện:** 
  1. Tạo thư mục `docs/`.
  2. Di chuyển `Architecture.md` và `AI_Notes.md` vào trong thư mục `docs/`.
  3. Tạo mới file `docs/UI_Design_Rules.md` chứa toàn bộ thông số thiết kế UI/UX tách từ `agent.md` sang.
  4. Cập nhật `agent.md`: Xóa phần UI chi tiết, thay bằng chỉ thị yêu cầu AI *chỉ được đọc* `docs/UI_Design_Rules.md` khi có task liên quan trực tiếp đến giao diện.
- **Lý do:** Người dùng yêu cầu gom tất cả các file tài liệu (trừ `agent.md`) vào chung thư mục `docs/` để gọn gàng; đồng thời tối ưu hóa việc AI đọc hiểu bằng cách không bắt AI đọc các thông số UI dài dòng khi đang xử lý các task Backend hay Database.
- **Mục đích:** Tránh phân mảnh tài liệu ở thư mục gốc. Giảm thiểu lượng token (ngữ cảnh) không cần thiết mà AI phải nạp khi xử lý các công việc không liên quan đến UI.
- **Lợi ích:** Cấu trúc dự án sạch sẽ hơn. AI phản hồi nhanh hơn và tập trung tốt hơn vào đúng chuyên môn của từng task được giao (code Backend thì không bị phân tâm bởi UI).

---

### [2026-08-29 21:44:00] Bổ sung quy tắc quản lý biến môi trường (Config/Env)
- **Các công việc đã thực hiện:** 
  1. Thêm Mục 3 "Quản lý Cấu hình & Biến môi trường" vào file `agent.md`.
  2. Quy định AI tuyệt đối không được hardcode các tham số có thể thay đổi (như API Keys, Database URL, Port...). Bắt buộc phải đưa ra file `.env` hoặc file cấu hình riêng biệt.
  3. Yêu cầu AI luôn phải tạo file `.env.example` hoặc template kèm chú thích để người dùng dễ dàng tùy chỉnh.
- **Lý do:** Người dùng muốn làm chủ cấu hình hệ thống, có thể dễ dàng thay đổi các thông số kết nối mà không cần phải hiểu sâu hay trực tiếp chỉnh sửa mã nguồn gốc do AI viết.
- **Mục đích:** Tách biệt rõ ràng giữa Code (Logic) và Config (Cấu hình), giúp dự án đạt chuẩn bảo mật và dễ triển khai trên nhiều môi trường (Local, Staging, Production).
- **Lợi ích:** Tránh việc rò rỉ API Keys/Mật khẩu khi đưa code lên Github. Giúp người dùng thoải mái tự vận hành hoặc thay đổi Database/Server tùy ý mà không sợ làm hỏng code.

## Cập nhật hệ thống - 2026-08-29
- 🕒 **Ngày giờ thực hiện:** 2026-08-29 21:45:00
- ✅ **Các công việc đã thực hiện:** Viết lại (format) file `agent.md` gọn gàng, sử dụng Markdown (emoji, blockquote, danh sách) để làm nổi bật nội dung.
- ❓ **Lý do:** Người dùng yêu cầu làm mới file `agent.md` cho đẹp và gọn gàng hơn.
- 🎯 **Mục đích:** Trình bày rõ ràng các hướng dẫn và quy tắc bắt buộc.
- 🚀 **Lợi ích:** Tăng trải nghiệm đọc, giúp các chỉ thị dễ nhìn và được nhấn mạnh tốt hơn.

## Cập nhật hệ thống - 2026-08-29
- **Ngày giờ thực hiện:** 2026-08-29 21:46:15
- **Các công việc đã thực hiện:** Loại bỏ toàn bộ icon (emoji) khỏi file `agent.md` theo yêu cầu của người dùng, giữ nguyên định dạng Markdown gọn gàng (danh sách, blockquote).
- **Lý do:** Người dùng không muốn sử dụng icon trong tài liệu hướng dẫn.
- **Mục đích:** Chỉnh sửa cách trình bày cho phù hợp với phong cách tài liệu mà người dùng mong muốn.
- **Lợi ích:** Giúp tài liệu nghiêm túc hơn và làm hài lòng người dùng trong khi vẫn duy trì cấu trúc mạch lạc, rõ ràng.

## Cập nhật hệ thống - 2026-08-29
- **Ngày giờ thực hiện:** 2026-08-29 21:51:00
- **Các công việc đã thực hiện:** 
  1. Phân tích kiến trúc tổng thể (Backend Node.js, Frontend Flutter cho User và Merchant).
  2. Tạo mới file `docs/Project_Directory_Structure.md` trình bày chi tiết từng thư mục, từng file (controller, service, lib, features...).
- **Lý do:** Người dùng yêu cầu giải thích và lên danh sách chi tiết các thư mục dự án sẽ có, bên trong chứa gì và chịu trách nhiệm gì.
- **Mục đích:** Khởi tạo "Bản đồ thư mục" (Directory Map) chuẩn xác nhất để làm cơ sở cho việc code sau này, đảm bảo không bị lộn xộn giữa các thành phần.
- **Lợi ích:** Người dùng dễ dàng hình dung toàn bộ quy mô dự án. Các AI Subagent sau này có thể đọc file này để biết chính xác nên đặt code mới vào thư mục nào cho đúng chuẩn MVC và Feature-based.

## Cập nhật hệ thống - 2026-08-29
- **Ngày giờ thực hiện:** 2026-08-29 21:54:00
- **Các công việc đã thực hiện:** Tạo file `task_tracker.md` tại thư mục gốc, phân tích toàn bộ README.md và roadmap để lập danh sách chi tiết các đầu mục công việc, từ thiết lập môi trường (Flutter, Node.js, Postgres) đến code API, code giao diện, và kế hoạch deploy cho 4 giai đoạn.
- **Lý do:** Người dùng yêu cầu tạo 1 file .md là task tracker để ghi ra các công việc cách chi tiết bám sát nội dung dự án.
- **Mục đích:** Làm bảng công việc (Todo List) thống nhất, chi tiết, giúp team theo dõi sát tiến độ phát triển và chia nhỏ task.
- **Lợi ích:** Ngăn chặn việc làm lan man, mất định hướng. Team và AI agent có thể biết task nào chưa hoàn thành ( `[ ]` ) để ưu tiên xử lý.

## Cập nhật hệ thống - 2026-08-29
- **Ngày giờ thực hiện:** 2026-08-29 22:00:00
- **Các công việc đã thực hiện:** 
  1. Di chuyển file `task_tracker.md` từ thư mục gốc vào trong thư mục `docs/`.
  2. Cập nhật file `agent.md`: Viết lại Mục 4, ép buộc AI mỗi khi code xong phải làm 2 việc: (1) Check `[x]` vào `docs/task_tracker.md`, (2) Ghi log chi tiết vào `docs/AI_Notes.md` với các trường bắt buộc mở rộng.
- **Lý do:** Người dùng yêu cầu gom task tracker vào thư mục `docs` và thiết lập một quy trình làm việc khắt khe: làm xong task nào phải tick hoàn thành, log chi tiết quá trình và ghi lại các thông số kỹ thuật.
- **Mục đích:** Đồng bộ hóa tiến độ công việc giữa AI và dự án thực tế. Buộc AI bàn giao lại chính xác các thông số (API, version, config) để con người hoặc các AI khác dễ dàng kế thừa.
- **Lợi ích:** Tránh tình trạng AI code xong quên cập nhật trạng thái làm mất phương hướng tiến độ. Quản trị thông số kỹ thuật minh bạch giúp dự án không bao giờ rơi vào rủi định "chỉ có AI mới hiểu code".
- **Thông tin cần lưu ý & Thông số kỹ thuật:** File quản lý task đã đổi đường dẫn thành `docs/task_tracker.md`. Định dạng log từ nay bắt buộc có thêm trường "Thông tin cần lưu ý & Thông số kỹ thuật".

## Cập nhật hệ thống - 2026-08-29
- **Ngày giờ thực hiện:** 2026-08-29 22:01:40
- **Các công việc đã thực hiện:** Chỉnh sửa file `docs/task_tracker.md`, loại bỏ hoàn toàn các task thuộc Giai đoạn 2 (Thử nghiệm thị trường), Giai đoạn 3 (Thương mại hóa) và Giai đoạn 4 (Mở rộng & AI). Chỉ giữ lại duy nhất Giai đoạn 1 (Phát triển MVP).
- **Lý do:** Theo thông báo từ người dùng, hiện tại dự án không phát triển đến các phase 2 và 3, chỉ tập trung vào phase 1.
- **Mục đích:** Dọn dẹp Task Tracker, giúp cho team và các AI agent tập trung 100% vào việc phát triển sản phẩm MVP lõi, tránh bị phân tâm bởi các task chưa cần thiết ở tương lai xa.
- **Lợi ích:** Bảng công việc trở nên ngắn gọn, thực tế và bám sát trực tiếp vào scope (phạm vi) hiện tại của dự án.
- **Thông tin cần lưu ý & Thông số kỹ thuật:** Các tính năng như Cloud Deployment, Analytics CRM, AI Recommendation và tích hợp Payment Gateway (e-Wallet) tạm thời bị loại bỏ khỏi scope hiện tại. Không sinh code cho các tính năng này cho đến khi có yêu cầu mới.

## Cập nhật hệ thống - 2026-08-29
- **Ngày giờ thực hiện:** 2026-08-29 22:08:00
- **Các công việc đã thực hiện:** Chỉnh sửa file `docs/Project_Directory_Structure.md`, cập nhật cấu trúc thư mục backend từ định dạng Express.js (.js, server.js) sang định dạng chuẩn của NestJS (.ts, main.ts, .module.ts, .controller.ts, .service.ts).
- **Lý do:** Team phát triển đã thống nhất sử dụng framework NestJS thay cho Express.js thuần.
- **Mục đích:** Khớp tài liệu cấu trúc thư mục với định hướng công nghệ cuối cùng, đảm bảo khi khởi tạo project sẽ chạy đúng template NestJS.
- **Lợi ích:** Tránh nhầm lẫn cho AI và các lập trình viên khác trong quá trình cài đặt môi trường và sinh code ban đầu. Hệ thống backend sẽ được hưởng lợi từ kiến trúc Module chặt chẽ của NestJS.
- **Thông tin cần lưu ý & Thông số kỹ thuật:** Từ nay mọi mã nguồn sinh ra cho backend bắt buộc phải dùng TypeScript và tuân thủ chặt chẽ nguyên lý Dependency Injection cũng như kiến trúc Module của NestJS. Không sử dụng cú pháp của Express.js thuần.

## Cập nhật hệ thống - 2026-08-29
- **Ngày giờ thực hiện:** 2026-08-29 22:09:00
- **Các công việc đã thực hiện:** Chỉnh sửa file `docs/Project_Directory_Structure.md`, xóa bỏ toàn bộ các biểu tượng icon (emoji) dùng để trang trí (như 🗂️, 🟢, 🔵, 🟠, 🎯).
- **Lý do:** Yêu cầu trực tiếp từ người dùng.
- **Mục đích:** Đồng nhất phong cách tài liệu, duy trì sự nghiêm túc và gọn gàng, tương tự như quy chuẩn áp dụng ở các file tài liệu khác (điển hình như `agent.md` trước đó).
- **Lợi ích:** Trình bày chuyên nghiệp hơn, văn bản sạch sẽ.
- **Thông tin cần lưu ý & Thông số kỹ thuật:** Định dạng cấu trúc thư mục vẫn tuân theo đúng cú pháp code block, chỉ thay đổi ở dạng plain text, không ảnh hưởng đến nội dung kỹ thuật.

## Cập nhật hệ thống - 2026-08-30
- **Ngày giờ thực hiện:** 2026-08-30 19:39:00
- **Các công việc đã thực hiện:**
  1. Phân tích toàn diện file `docs/task_tracker.md` cũ so sánh với `docs/Architecture.md`, `docs/Project_Directory_Structure.md` và `README.md`.
  2. Phát hiện 7 vấn đề: thiếu Dynamic QR, OTP login flow, FCM Push Notification, Admin Dashboard, task quá chung chung, thiếu Merchant Campaign/Report, không có task kiểm thử.
  3. Viết lại hoàn toàn `docs/task_tracker.md` với 8 nhóm task chi tiết (66 task con cụ thể, có thể thực hiện ngay).
- **Lý do:** Người dùng yêu cầu kiểm tra task tracker xem đã chi tiết, khả thi và phù hợp với dự án chưa.
- **Mục đích:** Đảm bảo mỗi task đủ cụ thể để AI Agent hoặc lập trình viên có thể thực hiện trực tiếp mà không cần hỏi thêm.
- **Lợi ích:** Task tracker mới bao phủ 100% tính năng từ Architecture.md, có đủ thứ tự dependency (DB Schema trước API, API trước Flutter), bao gồm cả tích hợp FCM và kiểm thử.
- **Thông tin cần lưu ý & Thông số kỹ thuật:**
  - Đăng nhập User: OTP qua số điện thoại (không dùng email/password).
  - Đăng nhập Merchant: email + password (bcrypt).
  - Dynamic QR: làm mới mỗi 60 giây, sinh từ JWT/User ID có timestamp.
  - Chống double-spending: dùng PostgreSQL Transaction + Row-Level Lock (`SELECT ... FOR UPDATE`).
  - ORM: TypeORM (không dùng Prisma).
  - Push Notification: Firebase Cloud Messaging (FCM).

## Cập nhật hệ thống - 2026-08-30

- **Ngày giờ thực hiện:** 2026-08-30 20:01:00
- **Các công việc đã thực hiện:**
  1. Sửa `docs/Architecture.md`: Thay Firebase Cloud Messaging bằng WebSocket (Socket.IO) trong Tech Stack và Luồng nghiệp vụ tích điểm.
  2. Sửa `docs/task_tracker.md`: Thay toàn bộ Section 1.5 (FCM) thành Section 1.5 (WebSocket). Cập nhật biến `.env.example` (`FCM_SERVER_KEY` → `WEBSOCKET_PORT`). Cập nhật task kiểm thử từ FCM sang WebSocket.
  3. Tạo mới `docs/Future_Development.md`: Ghi lại 7 tính năng ngoài scope MVP, trong đó Mục 1 ghi rõ lộ trình nâng cấp từ WebSocket lên FCM khi deploy production.
- **Lý do:** Người dùng xác định dự án chạy local, Firebase FCM không phù hợp vì yêu cầu internet và Google Server không thể gọi ngược vào localhost.
- **Mục đích:** Đơn giản hóa kiến trúc, phù hợp với mục tiêu demo MVP tại chỗ. Không phụ thuộc bên thứ 3.
- **Thông tin cần lưu ý & Thông số kỹ thuật:**
  - Push Notification hiện tại: **WebSocket (Socket.IO)** — chỉ hoạt động khi app đang mở.
  - Package NestJS: `@nestjs/websockets`, `@nestjs/platform-socket.io`.
  - Package Flutter: `socket_io_client`.
  - Cơ chế: Map `user_id` → `socket_id` lưu in-memory trong NestJS, emit sự kiện `points_earned`.
  - Khi deploy production: Tham khảo `docs/Future_Development.md` Mục 1 để nâng cấp lên FCM.

## Cập nhật hệ thống - 2026-08-30
- **Ngày giờ thực hiện:** 2026-08-30 20:08:00
- **Các công việc đã thực hiện:**
  1. Sửa `docs/Project_Directory_Structure.md`: Đổi `TypeORM/Prisma` thành chỉ `TypeORM` tại dòng mô tả thư mục `config/`.
  2. Sửa `docs/Architecture.md`: Bổ sung **TypeORM** vào mục Tech Stack (Backend), ghi rõ vai trò: định nghĩa Entity bằng TypeScript Decorator, quản lý Migration, hỗ trợ Raw Query.
- **Lý do:** Người dùng xác nhận quyết định cuối cùng chọn **TypeORM** làm ORM cho toàn bộ Backend. Không sử dụng Prisma.
- **Mục đích:** Đồng bộ hóa toàn bộ tài liệu. Xóa bỏ sự nhập nhằng "TypeORM/Prisma" còn sót lại, đảm bảo AI Agent trong tương lai không bị nhầm lẫn khi chọn thư viện.
- **Thông tin cần lưu ý & Thông số kỹ thuật:**
  - ORM được chọn: **TypeORM** (không phải Prisma).
  - Package cần cài: `@nestjs/typeorm`, `typeorm`, `pg`.
  - Entity khai báo bằng TypeScript Decorator (`@Entity`, `@Column`, `@PrimaryGeneratedColumn('uuid')`, `@ManyToOne`...).
  - Migration quản lý bằng TypeORM CLI, cấu hình trong `backend/src/config/database.config.ts`.

## Cập nhật hệ thống - 2026-08-30
- **Ngày giờ thực hiện:** 2026-08-30 20:19:00
- **Các công việc đã thực hiện:**
  1. Tạo mới `.gitignore` tại thư mục gốc: Bao gồm rule cho Node.js, Flutter/Dart, iOS, Android, và đặc biệt chặn file `.env`.
  2. Tạo mới `backend/.env.example`: File mẫu hướng dẫn cấu hình với đầy đủ comment tiếng Việt cho từng biến.
  3. Tạo mới `backend/.env`: File môi trường thực tế đã điền giá trị mặc định để chạy dev local ngay.
  4. Tạo mới `backend/src/config/database.config.ts`: File cấu hình TypeORM, export `typeOrmConfig` cho AppModule và `AppDataSource` cho TypeORM CLI (migration).
- **Lý do:** Người dùng yêu cầu tạo file config, env và gitignore để chuẩn bị môi trường khởi tạo dự án.
- **Mục đích:** Hoàn thiện tầng cấu hình nền tảng trước khi bắt đầu viết code. Đảm bảo bí mật không bị lộ lên Git.
- **Thông tin cần lưu ý & Thông số kỹ thuật:**
  - `.env` đã có giá trị mặc định: `DB_PASSWORD=123456`, `DB_NAME=tingting_db`, `JWT_SECRET=tingting_dev_secret_key_2026`.
  - **CẢNH BÁO:** Khi deploy Production, phải đổi `JWT_SECRET` thành chuỗi ngẫu nhiên dài và đặt `TYPEORM_SYNC=false`, dùng Migration thay thế.
  - Lệnh chạy migration: `npx typeorm migration:run -d src/config/database.config.ts`.
  - Package cần cài cho backend: `npm install @nestjs/typeorm typeorm pg dotenv`.

## Cập nhật hệ thống - 2026-08-30
- **Ngày giờ thực hiện:** 2026-08-30 20:41:00
- **Các công việc đã thực hiện:**
  1. Tạo mới `docker-compose.yml`: Định nghĩa 2 service — PostgreSQL 15 và pgAdmin 4. Dữ liệu được persist qua Docker volume `postgres_data`. PostgreSQL có healthcheck tự động.
  2. Tạo mới `docker/init.sql`: Script tự động kích hoạt extension `uuid-ossp` khi tạo container lần đầu.
  3. Tạo mới `backend/package.json`: Toàn bộ dependencies cho NestJS backend bao gồm TypeORM, JWT, WebSocket, Passport, bcrypt, class-validator. Bao gồm các npm scripts cho migration TypeORM.
  4. Cập nhật `agent.md`: Thêm **Mục 7** — Quy tắc bắt buộc cập nhật `docker-compose.yml`, `package.json`, `docker/init.sql` khi có thay đổi hạ tầng.
  5. Cập nhật `docs/DEVELOPER_GUIDE.md`: Bổ sung file Docker vào bảng file quan trọng, thêm mục Docker CLI commands với hướng dẫn chi tiết pgAdmin.
- **Lý do:** Người dùng yêu cầu tạo file docker-compose và requirements (package.json) cho dự án.
- **Mục đích:** Chuẩn hóa môi trường phát triển — mọi thành viên chỉ cần `docker-compose up -d` và `npm install` là có môi trường đồng nhất.
- **Thông tin cần lưu ý & Thông số kỹ thuật:**
  - PostgreSQL container: `tingting_postgres`, port `5432`, image `postgres:15-alpine`.
  - pgAdmin container: `tingting_pgadmin`, port `5050`, login: `admin@tingting.dev` / `admin123`.
  - Xóa sạch DB để test lại: `docker-compose down -v` rồi `docker-compose up -d`.
  - Toàn bộ dependencies backend đã có trong `backend/package.json`, chỉ cần `npm install`.
  - npm scripts migration đã được cấu hình sẵn: `npm run migration:generate`, `npm run migration:run`, `npm run migration:revert`.

## Cập nhật hệ thống - 2026-08-30
- **Ngày giờ thực hiện:** 2026-08-30 20:45:00
- **Các công việc đã thực hiện:**
  1. Cập nhật `agent.md`: Thêm **Mục 8 (Quy Tắc Kiểm Tra Toàn Diện Khi Chỉnh Sửa Code - Cross-Check Checklist)**.
- **Lý do:** Người dùng sử dụng lệnh `/goal` yêu cầu AI khi sửa code phải rà soát và cân nhắc các file liên quan để hoàn thành nhiệm vụ một cách toàn diện.
- **Mục đích:** Xây dựng checklist 10 file cốt lõi (task tracker, logs, env, package.json, docker-compose, config, docs, themes) mà AI bắt buộc phải đối chiếu mỗi khi sinh hoặc sửa code, đảm bảo sự đồng bộ tuyệt đối giữa code, tài liệu và hạ tầng.
- **Thông tin cần lưu ý & Thông số kỹ thuật:**
  - AI phải tuân thủ nghiêm ngặt checklist này, bất kỳ sự thiếu sót nào trong việc cập nhật các file liên quan sẽ bị coi là chưa hoàn thành nhiệm vụ.

### Cập nhật ngày 30/08/2026 (Theo yêu cầu người dùng)
- **Ngày giờ thực hiện:** 2026-08-30T20:58:00+07:00
- **Các công việc đã thực hiện:**
  1. Xóa file `docs/Project_Directory_Structure.md`.
  2. Xóa các liên kết/chỉ mục đến file `Project_Directory_Structure.md` trong các tài liệu `docs/task_tracker.md` và `docs/DEVELOPER_GUIDE.md`.
  3. Cập nhật `docker-compose.yml`: sử dụng `env_file: - ./backend/.env` cho service `postgres` thay vì `environment`.
  4. Bổ sung các biến `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB` vào `backend/.env` và `backend/.env.example` để phục vụ trực tiếp cho image của Docker.
  5. Cập nhật `healthcheck` trong `docker-compose.yml` để sử dụng `$$POSTGRES_USER` và `$$POSTGRES_DB`.
- **Lý do làm:** File cấu trúc thư mục đã lỗi thời sau khi cấu hình Monorepo và thêm Docker. Đồng thời tối ưu cấu hình Docker Compose để kết nối trực tiếp với file cấu hình của Backend, tránh nguy cơ lỗi mật khẩu dự phòng.
- **Mục đích:** Đồng nhất tài liệu hướng dẫn và đảm bảo mọi biến môi trường liên quan đến Database chỉ lấy từ một nguồn sự thật (single source of truth) duy nhất là `backend/.env`.
- **Lợi ích:** Đảm bảo `docker-compose up -d` hoạt động chính xác 100% không cần truyền thêm tham số, tự động cập nhật nếu user thay đổi cấu hình trong `.env`.
- **Thông tin cần lưu ý & Thông số kỹ thuật:** Trong `docker-compose.yml`, dùng kí hiệu `$$` trong script CMD-SHELL của `healthcheck` để docker-compose bỏ qua quá trình tự map biến và dùng biến trực tiếp từ container (được nạp qua `env_file`).

## Cập nhật hệ thống - 2026-08-30 (Theo yêu cầu người dùng)
- **Ngày giờ thực hiện:** 2026-08-30 21:23:00
- **Các công việc đã thực hiện:**
  1. Ghi nhận phản hồi quyết định 10 vấn đề từ file `project_decisions.md`.
  2. Tạo mới file `docs/Future_Development.md` chứa các hạng mục không thuộc MVP (Tặng Voucher, SMS thật, Deploy Cloud, Admin Dashboard, Admin-issued Voucher).
  3. Tạo mới file `docs/developer_guide.md` - sổ tay lập trình viên cực kỳ chi tiết bao gồm Kiến trúc, Tech Stack, Cấu hình linh hoạt (Points Ratio, Membership), và giải thích chuyên sâu các logic khó (Row-level lock chống double spending, Dynamic QR chống gian lận) phục vụ cho CV và dev sau này.
  4. Chuẩn bị cập nhật lại `task_tracker.md` để khớp 100% với các thay đổi (Sẽ thực hiện bước tiếp theo).
- **Lý do:** Người dùng thực thi lệnh `/goal`, yêu cầu ghi lại toàn bộ thông số, kỹ thuật, cấu hình vào một guide chi tiết cho lập trình viên và CV sau khi đã chốt các quyết định tính năng.
- **Mục đích:** Đồng nhất tầm nhìn kiến trúc, lưu trữ lại tư duy kỹ thuật giải quyết vấn đề (Problem-solving) để team lấy tư liệu chứng minh năng lực. Giảm tải MVP để focus vào cốt lõi.
- **Lợi ích:** Developer Guide trở thành "kim chỉ nam" kỹ thuật của dự án. Future Development giúp dự án không bị vứt bỏ các ý tưởng hay mà chỉ đơn giản là hoãn lại.
- **Thông tin cần lưu ý & Thông số kỹ thuật:**
  - `POINTS_RATIO` và `MEMBERSHIP_TIERS` bắt buộc phải là biến cấu hình, không hardcode.
  - Merchant App: Cần có giao diện quy định hạn mức điểm khi tạo Voucher.
  - OTP MVP dùng Mock `000000`. Backend chạy Local.

## Khắc phục lỗi - 2026-08-30 21:30
- **Ngày giờ thực hiện:** 2026-08-30 21:30:00
- **Các công việc đã thực hiện:**
  1. Xóa file `developer_guide.md` (viết thường) do tạo nhầm.
  2. Hợp nhất nội dung CV Highlights, Tech Stack, và Config-Driven vào file `DEVELOPER_GUIDE.md` gốc của người dùng.
- **Lý do:** Người dùng phản hồi AI đã ghi đè nhầm tạo file mới thay vì sửa file cũ (do khác biệt in hoa/thường trên Linux).
- **Mục đích:** Khôi phục cấu trúc tài liệu của người dùng, tích hợp các yêu cầu bổ sung vào đúng vị trí.
- **Lợi ích:** Đảm bảo tài liệu không bị phân mảnh và giữ lại được công sức viết script Docker/CLI của người dùng.

## Ghi nhận Sự cố & Xác nhận Scope dự án - 2026-08-30 21:39
- **Ngày giờ thực hiện:** 2026-08-30 21:39:00
- **Các công việc đã thực hiện:**
  1. Ghi nhận sự cố AI làm mất dữ liệu của người dùng trong file `Future_Development.md` do sử dụng sai toán tử ghi đè.
  2. Rà soát lại toàn bộ `docs/DEVELOPER_GUIDE.md` (đã merge thành công nội dung của team Dev và AI) và `docs/task_tracker.md` để đảm bảo 100% các quyết định của MVP được giữ nguyên.
- **Lý do:** Người dùng yêu cầu ghi nhận lại trạng thái hiện tại sau sự cố thao tác file để theo dõi minh bạch quá trình AI làm việc.
- **Mục đích:** Đảm bảo quá trình log theo đúng chỉ thị bắt buộc trong `agent.md`. Rút kinh nghiệm việc đọc file trước khi ghi.
- **Lợi ích:** Team phát triển có thể theo dõi được sai sót của AI, hiểu được lý do tại sao file `Future_Development.md` bị thay đổi. Củng cố quy tắc an toàn dữ liệu.
- **Thông tin cần lưu ý & Thông số kỹ thuật:**
  - AI bị cấm dùng lệnh `cat >` (ghi đè toàn bộ) đối với các file đã tồn tại mà chưa đọc nội dung. Khuyến khích dùng python script hoặc đọc file trước khi sửa để bảo toàn công sức của người dùng.
  - Các thông số kỹ thuật MVP đã chốt: OTP `000000`, Deploy Local, Điểm/Hạng cấu hình động, không có Tặng Voucher/Admin Dashboard.

## Tái Cấu Trúc File Quy Tắc AI - 2026-08-30
- **Ngày giờ thực hiện:** 2026-08-30 21:40:00
- **Các công việc đã thực hiện:**
  1. Tạo `docs/CODE_STANDARDS.md`: Trích xuất toàn bộ Mục 6 (Tiêu Chuẩn Viết Code) từ `agent.md` sang file mới, bao gồm template header và quy tắc viết comment.
  2. Tạo `docs/CROSS_CHECK.md`: Trích xuất toàn bộ Mục 8 (Checklist Kiểm Tra Chéo) từ `agent.md` sang file mới, chuyển thành dạng checkbox để dễ rà soát.
  3. Viết lại toàn bộ `agent.md` theo hướng ngắn gọn: Chỉ giữ lại các quy tắc cốt lõi và tham chiếu đến `CODE_STANDARDS.md` khi viết code, tham chiếu đến `CROSS_CHECK.md` sau khi sửa code.
- **Lý do:** Người dùng yêu cầu `agent.md` phải gọn gàng, không ghi nhồi nhét quá nhiều chi tiết, các phần liên quan có thể tách ra file `.md` riêng trong `docs/` để khi nào dùng mới đọc.
- **Mục đích:** Tối ưu hóa dung lượng file quy tắc gốc (`agent.md`), giúp AI xử lý ngữ cảnh nhanh hơn, tránh tràn token, đồng thời tăng tính dễ đọc cho người thật.
- **Lợi ích:** Hệ thống tài liệu gọn gàng, module hóa. AI chỉ đọc các file chi tiết (`CODE_STANDARDS.md`, `CROSS_CHECK.md`) đúng vào thời điểm cần thiết (trước khi code và sau khi code).
- **Thông tin cần lưu ý & Thông số kỹ thuật:**
  - AI vẫn bị ràng buộc hoàn toàn bởi tất cả các quy tắc đã được tách ra.

## Hoàn thành Task 1.1 Khởi tạo dự án & Cấu hình môi trường - 2026-08-31
- **Ngày giờ thực hiện:** 2026-08-31 14:12:00
- **Các công việc đã thực hiện:**
  1. Khởi tạo Git repository và add `.gitignore`.
  2. Tạo 2 dự án Flutter `app_user` và `app_merchant`.
  3. Thêm các thư viện Flutter cần thiết (dio, flutter_riverpod, go_router, mobile_scanner, qr_flutter, shared_preferences).
  4. Tạo cấu trúc `lib/core` chứa `theme.dart` và `api_client.dart` cho cả 2 dự án Flutter.
  5. Cập nhật `backend/.env.example` và `backend/.env` với các biến config: FCM_SERVER_KEY, POINTS_RATIO, MEMBERSHIP_TIERS_CONFIG.
  6. Sinh các file TypeScript khởi tạo NestJS (`main.ts`, `app.module.ts`, `app.controller.ts`, `app.service.ts`) vào thư mục `backend/src`.
  7. Đánh dấu hoàn thành Task 1.1 trong `docs/task_tracker.md`.
- **Lý do:** Người dùng yêu cầu thực hiện Task 1.1.
- **Mục đích:** Xây dựng khung sườn cho backend và hai app frontend, chuẩn bị môi trường và cấu hình các biến cơ bản cho giai đoạn phát triển tiếp theo.
- **Lợi ích:** Hệ thống đã sẵn sàng thư viện, base code NestJS và Flutter, giúp bắt đầu ngay vào việc code chức năng (Task 1.2).
- **Thông tin cần lưu ý & Thông số kỹ thuật:**
  - Các app Flutter đã dùng các biến cấu hình từ `theme.dart` với mã màu Vàng `#FAD240` và Hồng `#E8687D` chuẩn thiết kế.
  - `backend/.env` đã đầy đủ biến kết nối DB và cấu hình nghiệp vụ.

## Đồng bộ hóa kiến trúc WebSocket thay cho FCM - 2026-08-31
- **Ngày giờ thực hiện:** 2026-08-31 15:33:00
- **Các công việc đã thực hiện:**
  1. Xóa bỏ các từ khóa liên quan đến FCM (Firebase Cloud Messaging) bị sót lại trong các tài liệu.
  2. Cập nhật Mục 1.5 trong `docs/task_tracker.md` thành "Tích hợp WebSocket (Real-time Notification)".
  3. Đổi biến `FCM_SERVER_KEY` thành `WEBSOCKET_PORT` trong `docs/DEVELOPER_GUIDE.md`, `backend/.env.example` và `backend/.env`.
- **Lý do:** Khách hàng review tài liệu và phát hiện ra sự bất đồng nhất (tài liệu vẫn ghi dùng FCM mặc dù đã thống nhất dùng WebSocket cho môi trường deploy Localhost).
- **Mục đích:** Khắc phục lỗi sai sót của AI trong quá trình cập nhật tài liệu trước đó, đảm bảo toàn bộ dự án từ docs đến file cấu hình đều đồng bộ 100% về kiến trúc WebSocket.
- **Lợi ích:** Tránh gây nhầm lẫn cho developer khi đọc tài liệu và khi bắt đầu code tính năng Push Notification.
- **Thông tin cần lưu ý & Thông số kỹ thuật:**
  - Dự án không sử dụng Firebase cho tính năng push notification (do khó gọi từ localhost).
  - Sử dụng Socket.IO tại cổng cấu hình `WEBSOCKET_PORT=3001` để thay thế.

## Đánh dấu hoàn thành 5 Entity thuộc Task 1.2 - 2026-08-31
- **Ngày giờ thực hiện:** 2026-08-31 15:35:00
- **Các công việc đã thực hiện:**
  1. Kiểm tra xác nhận 5 Entity (Users, Merchants, Transactions, Vouchers, UserVouchers) đã được tạo và đặt chuẩn trong `backend/src/modules/*/entities/`.
  2. Cập nhật `docs/task_tracker.md` đánh dấu hoàn thành (`[x]`) cho 5 task tạo Entity đầu tiên trong mục 1.2.
- **Lý do:** Người dùng yêu cầu tạo Entity (5 dòng đầu) mục 1.2. Qua kiểm tra mã nguồn, các Entity này đã được tạo từ trước. Vì thế tiến hành đối chiếu và đánh dấu hoàn thành.
- **Mục đích:** Cập nhật Task Tracker đúng với trạng thái thực tế của mã nguồn để chuẩn bị cho các công việc tiếp theo (Migration và Seed).
- **Lợi ích:** Tránh việc tạo lại code trùng lặp, đảm bảo Task Tracker phản ánh chính xác tình trạng dự án.
- **Thông tin cần lưu ý & Thông số kỹ thuật:**
  - Các Entity đã dùng TypeORM (`@Entity`, `@PrimaryGeneratedColumn('uuid')`).
  - Vị trí: `backend/src/modules/{tên_module}/entities/*.entity.ts`.

## Sinh file TypeORM Migration - 2026-08-31
- **Ngày giờ thực hiện:** 2026-08-31 22:50:00
- **Các công việc đã thực hiện:**
  1. Chạy lệnh `docker compose up -d` để khởi động container PostgreSQL.
  2. Sửa lỗi `fallthroughCasesInSwitch` trong `tsconfig.json`.
  3. Hướng dẫn người dùng chạy lệnh `npm run typeorm -- migration:generate src/migrations/InitTables -d src/config/database.config.ts` để sinh file migration thành công.
- **Lý do:** Thực hiện công việc thuộc Task 1.2, cần tạo cấu trúc database thực tế từ các file Entity.
- **Mục đích:** Tự động sinh ra câu lệnh SQL tạo bảng mà không cần gõ tay.
- **Lợi ích:** Đồng bộ 100% giữa code Backend và cấu trúc Database.
- **Thông tin cần lưu ý & Thông số kỹ thuật:**
  - File sinh ra nằm ở `backend/src/migrations/`.
  - Đối với các dev tham gia dự án sau hoặc khi clone code ở máy mới: KHÔNG CẦN chạy lệnh sinh (`migration:generate`) lại, chỉ cần chạy `npm run migration:run`.

## Cập nhật SETUP.md để đồng bộ quy trình Migration - 2026-08-31
- **Ngày giờ thực hiện:** 2026-08-31 22:57:00
- **Các công việc đã thực hiện:**
  1. Cập nhật file `SETUP.md` bổ sung Bước 2.5 `npm run migration:run`.
  2. Đánh dấu `[x]` hoàn thành task "Viết TypeORM migration tạo bảng" trong `docs/task_tracker.md`.
- **Lý do:** Khắc phục sự thiếu sót trong file `SETUP.md` cũ (dựa dẫm vào tính năng tự động tạo bảng `TYPEORM_SYNC=true` vốn không khuyên dùng cho dự án thực tế).
- **Mục đích:** Chuẩn hóa quy trình cài đặt cho các lập trình viên sau này, dùng migration để quản lý Database.
- **Lợi ích:** Đảm bảo tính nhất quán của cấu trúc Database giữa các thành viên trong team.
- **Thông tin cần lưu ý & Thông số kỹ thuật:**
  - File `SETUP.md` đã hoàn toàn đồng bộ với chuẩn làm việc dùng TypeORM Migration của dự án.

## Tắt tính năng tự động tạo bảng TYPEORM_SYNC - 2026-08-31
- **Ngày giờ thực hiện:** 2026-08-31 23:01:00
- **Các công việc đã thực hiện:**
  1. Đổi `TYPEORM_SYNC=true` thành `false` trong `backend/.env`.
  2. Đổi `TYPEORM_SYNC=true` thành `false` trong `backend/.env.example`.
  3. Cập nhật `SETUP.md` ở phần biến môi trường và phần gỡ lỗi thường gặp, chuyển hướng dẫn từ việc bật `TYPEORM_SYNC` sang sử dụng lệnh Migration.
- **Lý do:** Người dùng phát hiện biến `TYPEORM_SYNC` vẫn còn bật (`true`). Nếu để `true`, quá trình chạy server có thể gây xung đột với các thao tác của TypeORM Migration.
- **Mục đích:** Tách biệt hoàn toàn nhiệm vụ tạo/sửa bảng (do Migration đảm nhiệm) khỏi quá trình chạy app (chỉ thực thi logic).
- **Lợi ích:** Tránh lỗi ghi đè cấu trúc bảng, bảo vệ dữ liệu an toàn.
- **Thông tin cần lưu ý & Thông số kỹ thuật:**
  - Từ thời điểm này, toàn bộ việc thay đổi cấu trúc database PHẢI thông qua các file trong `src/migrations`. Việc chạy lại server bằng `npm run start:dev` sẽ không tác động đến DB nữa.

## Bật lại TYPEORM_SYNC cho MVP và Cập nhật định hướng - 2026-08-31
- **Ngày giờ thực hiện:** 2026-08-31 23:04:00
- **Các công việc đã thực hiện:**
  1. Đổi lại `TYPEORM_SYNC=true` trong `backend/.env` và `backend/.env.example`.
  2. Khôi phục lại tài liệu `SETUP.md`: bỏ bước chạy `npm run migration:run`, giữ nguyên hướng dẫn chạy thẳng `npm run start:dev` để tiện dụng.
  3. Bổ sung ghi chú vào `docs/Future_Development.md` mục "1. Hạ tầng & Triển khai" về việc bắt buộc phải chuyển sang dùng TypeORM Migration (TYPEORM_SYNC=false) khi phát triển mở rộng hoặc đưa lên Production.
- **Lý do:** Người dùng muốn ưu tiên sự tiện dụng tối đa cho người cài đặt MVP (chỉ cần chạy 1 lệnh là xong), đồng thời vẫn lưu ý rủi ro cho tương lai.
- **Mục đích:** Cân bằng giữa sự tiện lợi của MVP và chuẩn mực kỹ thuật của Production.
- **Lợi ích:** Trải nghiệm cài đặt Local/Demo mượt mà hơn.
- **Thông tin cần lưu ý & Thông số kỹ thuật:**
  - Đối với bản MVP hiện tại: Mọi người chỉ cần chạy `npm run start:dev` là tự có bảng nhờ phép thuật của `TYPEORM_SYNC=true`.
  - Hướng dẫn dùng Migration đã được chuyển vào `docs/Future_Development.md` để dọn đường cho phase sau.

## Bổ sung hướng dẫn Seed Data vào SETUP.md - 2026-08-31
- **Ngày giờ thực hiện:** 2026-08-31 23:20:00
- **Các công việc đã thực hiện:**
  1. Thêm Bước 2.6 (Nạp dữ liệu mẫu - Seed Data) vào file `SETUP.md`.
  2. Ghi rõ lưu ý chỉ chạy lệnh `npm run seed` sau khi đã khởi động server (để đảm bảo bảng đã được TypeORM tạo).
- **Lý do:** Người dùng yêu cầu bổ sung lệnh nạp dữ liệu mẫu vào tài liệu cài đặt chung.
- **Mục đích:** Giúp các dev sau hoặc người xem demo nhanh chóng có môi trường đầy đủ dữ liệu (Users, Merchants, Vouchers) mà không cần tạo bằng tay.
- **Lợi ích:** Tiết kiệm thời gian test và đảm bảo app hiển thị đầy đủ UI ngay lần mở đầu tiên.
- **Thông tin cần lưu ý & Thông số kỹ thuật:**
  - Lệnh seed chỉ dành cho môi trường dev/demo. Cấm dùng cho Production.

## Sửa lỗi TypeORM khi chạy Seed Data - 2026-08-31
- **Ngày giờ thực hiện:** 2026-08-31 23:22:00
- **Các công việc đã thực hiện:**
  1. Cập nhật `backend/src/seeds/seed.ts`.
  2. Thay thế lệnh `repository.delete({})` bằng `repository.createQueryBuilder().delete().execute()`.
- **Lý do:** Các phiên bản TypeORM mới có cơ chế an toàn ngăn chặn việc dùng lệnh `.delete({})` (Empty criteria) để xóa toàn bộ dữ liệu trong bảng, gây ra lỗi khi người dùng cố gắng nạp dữ liệu mẫu.
- **Mục đích:** Đảm bảo script seed data chạy thành công mà không bị crash.
- **Lợi ích:** Fix triệt để bug khi clear database trước khi seed.
- **Thông tin cần lưu ý & Thông số kỹ thuật:**
  - Lỗi gặp phải: `TypeORMError: Empty criteria(s) are not allowed for the delete method`.

## Bổ sung cảnh báo an toàn cho lệnh Seed - 2026-08-31
- **Ngày giờ thực hiện:** 2026-08-31 23:24:00
- **Các công việc đã thực hiện:** Cập nhật file `SETUP.md` (Bước 2.6) bổ sung dòng cảnh báo in đậm rằng lệnh `npm run seed` sẽ xóa sạch toàn bộ dữ liệu cũ.
- **Lý do:** Người dùng yêu cầu ghi chú rõ ràng để các dev khác không bị mất dữ liệu oan uổng.
- **Mục đích:** Tăng cường cảnh báo rủi ro về mặt an toàn dữ liệu.
- **Lợi ích:** Tránh thảm họa xóa nhầm dữ liệu test quan trọng khi ai đó vô tình chạy lại lệnh seed.

## Đánh dấu hoàn thành toàn bộ Task 1.2 - 2026-08-31
- **Ngày giờ thực hiện:** 2026-08-31 23:29:00
- **Các công việc đã thực hiện:** Kiểm tra và đánh dấu `[x]` cho mục "Viết script seed data" trong `docs/task_tracker.md`.
- **Lý do:** Người dùng yêu cầu kiểm tra xem còn sót mục nào trong Task 1.2 chưa tick hoàn thành không trước khi push code.
- **Mục đích:** Đảm bảo Task Tracker phản ánh chính xác trạng thái thực tế.
- **Lợi ích:** Đóng lại một chặng của dự án, chuyển sang Task 1.3 với tài liệu gọn gàng.
- **Thông tin cần lưu ý & Thông số kỹ thuật:**
  - Task 1.2 (Thiết kế Database Schema & Seed Data) đã hoàn thành 100%.

## Cập nhật hệ thống - 2026-08-31
- **Ngày giờ thực hiện:** 2026-08-31 23:17:00
- **Các công việc đã thực hiện:**
  1. Cập nhật file `docs/DEVELOPER_GUIDE.md`: Bổ sung thông tin tài khoản đăng nhập pgAdmin (`admin@tingting.dev` / `admin123`) và chuỗi kết nối PostgreSQL (`postgresql://postgres:123456@localhost:5432/tingting_db`) vào phần hướng dẫn khởi chạy Docker.
- **Lý do:** Giúp các lập trình viên dễ dàng tra cứu thông tin đăng nhập giao diện pgAdmin và DB trực tiếp từ tài liệu hướng dẫn mà không cần phải mở xem nội dung file `docker-compose.yml` hay `.env`.
