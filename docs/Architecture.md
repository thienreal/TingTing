# Sườn Chi Tiết: Xây Dựng Hệ Thống Tích Điểm & Đổi Thưởng Tập Trung
*(Dựa trên phân tích UI/UX từ các ảnh chụp hệ thống mẫu - tương tự TAPTAP/TingTing)*

---

## 1. Tổng quan hệ thống (System Overview)
Hệ thống là một nền tảng Loyalty & Rewards (Khách hàng thân thiết & Đổi thưởng) đa thương hiệu. Nền tảng kết nối Người dùng cuối (B2C) và Doanh nghiệp/Cửa hàng (B2B) thông qua một đồng tiền ảo chung (ví dụ: điểm VUI).

### Các thành phần (Modules) cốt lõi:
1. **End-user Mobile App (iOS/Android):** Dành cho khách hàng tích điểm, đổi voucher và chơi game.
2. **Merchant App:** App dành riêng cho cửa hàng (cài trên điện thoại/máy tính bảng) để quét mã khách hàng, phát hành điểm và chấp nhận voucher.
3. **Admin Dashboard:** Dành cho ban quản trị nền tảng để vận hành, đối soát và cấu hình hệ thống.
4. **Backend Services & API:** Hệ thống máy chủ xử lý logic nghiệp vụ, lưu trữ dữ liệu.

---

## 2. Phân tích Tính năng chi tiết (Feature Breakdown)

### A. Mobile App (Người dùng cuối)
*Dựa trên các tab điều hướng và màn hình trong ảnh chụp.*

**1. Xác thực & Tài khoản (Authentication & Profile)**
- **Đăng nhập/Đăng ký:** Qua số điện thoại + OTP (Giới hạn thiết bị đăng nhập để chống gian lận).
- **Hồ sơ cá nhân:** Thông tin người dùng, Lịch sử giao dịch (Tích/Tiêu điểm).
- **Hạng thành viên (Membership Tier):** (VD: VUI Silver, Gold) đi kèm các đặc quyền riêng.

**2. Trang chủ (Home)**
- Banner quảng cáo các chiến dịch Hot.
- Số dư điểm hiện tại.
- Lối tắt nhanh: Mã QR của tôi (để đưa cho thu ngân quét).
- Gợi ý ưu đãi cá nhân hóa.

**3. Tích điểm (Earn Points)**
- Hiển thị Barcode/QR code định danh duy nhất của người dùng.
- Tự động thay đổi mã QR (Dynamic QR) mỗi 30-60 giây để bảo mật, chống chụp màn hình.

**4. Đổi thưởng (Rewards / Marketplace)**
- **Phân loại Deal:** Deal Hời Mua Sắm, Deal Ăn Uống, Voucher Giải Trí (VD: Jump Arena).
- **Danh sách ưu đãi:** Hiển thị hình ảnh, tên thương hiệu, mức giảm giá, và **số điểm cần để đổi** (VD: 300 VUI, 1000 VUI).
- **Chi tiết Ưu đãi:** 
  - Điều kiện áp dụng, Hạn sử dụng, Hạn mức sử dụng (Số lần tối đa).
  - Nút **"Đổi ngay"**.
  - Tích hợp bản đồ (Google Maps API) để tìm cửa hàng áp dụng gần nhất.

**5. Quản lý Ưu đãi của bạn (My Vouchers)**
- Phân loại trạng thái: 
  - **Đang có:** Các voucher chưa sử dụng.
  - **Đã dùng:** Lịch sử dùng voucher.
  - **Đã tặng:** Tính năng tặng voucher cho bạn bè qua số điện thoại.
  - **Hết hạn.**
- Hiển thị QR/Barcode của thẻ voucher khi bấm vào để thu ngân quét.


---

### B. Merchant App (Dành riêng cho Cửa hàng đối tác)
- **Tích điểm cho khách:** Nhập số tiền hóa đơn -> Quét mã QR của khách -> Hệ thống tự tính điểm (VD: 10.000đ = 1 điểm).
- **Áp dụng Voucher:** Quét mã Voucher của khách -> Trừ ưu đãi trên hóa đơn.
- **Quản lý Chiến dịch (Campaign Management):** Tạo e-voucher, thiết lập số lượng, điều kiện áp dụng, điểm quy đổi.
- **Báo cáo đối soát:** Thống kê lượng khách đến từ nền tảng, số lượng voucher đã tiêu thụ, công nợ với nền tảng.

---

### C. Admin Dashboard (Dành cho Chủ nền tảng)
- **Quản lý Đối tác (Merchants):** Duyệt đối tác mới, cài đặt tỷ lệ chiết khấu (Commission rate).
- **Quản lý Người dùng (Users):** Khóa tài khoản gian lận, truy xuất log giao dịch.
- **Quản lý Nội dung (CMS):** Cấu hình Banner trang chủ, quản lý danh mục Voucher.
- **Đối soát tài chính (Clearing & Settlement):** Tính toán dòng tiền cần thanh toán cho Merchant khi khách dùng điểm/voucher.

---

## 3. Kiến trúc Hệ thống (System Architecture)

### A. Công nghệ Đề xuất (Tech Stack)
- **Mobile App (Khách hàng & Doanh nghiệp):** Flutter (Sử dụng chung một công nghệ để phát triển cả App cho User và App dành riêng cho Merchant, giúp tối ưu chi phí và tận dụng lại code).
- **Backend:** 
  - **Node.js:** Xử lý các API I/O concurrency cao, ngôn ngữ dễ tiếp cận và phát triển cực kỳ nhanh chóng (đề xuất dùng NestJS hoặc Express).
  - **TypeORM:** ORM chính thức được sử dụng để tương tác với PostgreSQL. Định nghĩa bảng qua Entity class (TypeScript Decorator), quản lý thay đổi cấu trúc bảng qua Migration, hỗ trợ Raw Query cho các truy vấn thống kê phức tạp.
  - **WebSocket (Socket.IO):** Xử lý thông báo real-time (Push Notification) cho User khi app đang mở. Phù hợp với môi trường chạy local, không cần internet bên ngoài.
  - Kiến trúc Microservices (Tách biệt: User Service, Point Service, Voucher Service, Notification Service).
- **Database:**
  - **PostgreSQL:** Sử dụng làm Database duy nhất cho toàn bộ hệ thống (Lưu User, Điểm số, Danh sách Voucher, Lịch sử giao dịch). Đây là cơ sở dữ liệu quan hệ mạnh mẽ, đảm bảo tính ACID chặt chẽ (chống mất điểm, sai sót giao dịch) và rất tối ưu cho mô hình dự án khởi nghiệp/demo để tiết kiệm tài nguyên.

### B. Các Luồng Nghiệp Vụ Chính (Core Workflows)

**Luồng 1: Tích điểm tại quầy**
1. Khách mở App, đưa mã QR "Tích điểm".
2. Thu ngân dùng máy POS/App Merchant quét mã QR.
3. POS gửi request: `[QR_Code, Amount, Merchant_ID]` lên Backend.
4. Backend kiểm tra tính hợp lệ -> Cộng điểm cho User -> Sinh log giao dịch.
5. Bắn Real-time Notification qua **WebSocket** về App khách: "Bạn vừa được cộng X điểm" (yêu cầu App đang mở, phù hợp với môi trường chạy local).

**Luồng 2: Đổi Voucher**
1. Khách bấm "Đổi ngay" voucher tốn 300 điểm.
2. Backend lock dòng dữ liệu User (Transaction / Mutex Lock) để tránh lỗi Double-spending (Đổi 2 lần cùng 1 lúc).
3. Kiểm tra số dư (>= 300) -> Kiểm tra tồn kho Voucher (>0).
4. Trừ điểm -> Thêm Voucher vào bảng `User_Vouchers` -> Unlock dữ liệu.
5. App hiển thị thông báo thành công.
