# 🚀 Định hướng Phát triển Tương lai (Future Development)

Tài liệu này ghi nhận các tính năng, hạ tầng và kế hoạch mở rộng đã được thảo luận nhưng quyết định **không đưa vào Giai đoạn 1 (MVP)** nhằm tối ưu hóa thời gian và nguồn lực cho cuộc thi. Các hạng mục này sẽ được triển khai trong các giai đoạn tiếp theo của dự án TingTing.

---

## 1. Hạ tầng & Triển khai (Infrastructure & Deployment)
- **Triển khai thực tế (Cloud Deployment):** Hiện tại hệ thống (Backend Node.js & PostgreSQL) đang chạy trên môi trường Local. Trong tương lai, hệ thống sẽ được deploy lên các nền tảng Cloud thực tế (như AWS, Google Cloud, hoặc VPS DigitalOcean, Vultr) để vận hành chính thức và mở rộng quy mô.
- **Bảo mật Database (TypeORM Migration):** Để tiện cho người dùng test MVP chỉ với một lệnh `npm run start:dev`, biến `TYPEORM_SYNC` đang được đặt là `true` (tự động tạo bảng). Trong giai đoạn triển khai thực tế (Production) hoặc khi phát triển mở rộng, BẮT BUỘC phải đổi `TYPEORM_SYNC=false` và chuyển sang sử dụng TypeORM Migrations (`npm run migration:run`) để tránh rủi ro mất mát hoặc xung đột cấu trúc dữ liệu.
- **Tích hợp SMS OTP Thực tế:** Thay thế cơ chế Mock OTP (`000000`) hiện tại bằng việc tích hợp các nhà cung cấp dịch vụ SMS Gateway thật (Twilio, ESMS.vn, Stringee) để gửi mã xác thực đến số điện thoại người dùng.

## 2. Admin Dashboard (Hệ thống Quản trị Nền tảng)
- Xây dựng một Web Portal (VD: sử dụng ReactJS / Next.js) dành riêng cho Ban quản trị nền tảng TingTing với các chức năng:
  - **Quản lý Đối tác (Merchants):** Duyệt đối tác mới, quản lý hợp đồng, cài đặt tỷ lệ chiết khấu (Commission rate).
  - **Quản lý Người dùng (Users):** Quản lý tài khoản, khóa tài khoản gian lận, truy xuất log giao dịch.
  - **Quản lý Nội dung (CMS):** Cấu hình Banner trang chủ, quản lý danh mục Voucher, gửi Push Notification toàn hệ thống.
  - **Đối soát tài chính (Clearing & Settlement):** Tính toán dòng tiền cần thanh toán cho Merchant khi khách dùng điểm/voucher.

## 3. Tính năng cốt lõi mở rộng
- **Tặng Voucher cho bạn bè (Gift Voucher):** Cho phép người dùng chuyển nhượng, tặng các E-Voucher đang sở hữu cho số điện thoại của người dùng khác trong nền tảng.
- **Admin-Issued Vouchers (Voucher Nền tảng):** Hiện tại việc tạo và quản lý cấu hình Voucher hoàn toàn do Merchant quyết định. Trong tương lai, Admin nền tảng sẽ có quyền phát hành các Voucher chung (sử dụng chéo được ở nhiều chuỗi cửa hàng khác nhau) phục vụ cho các chiến dịch Marketing lớn của TingTing.

## 4. Trí tuệ Nhân tạo & Cá nhân hóa (AI & Recommendation)
- Tích hợp AI để phân tích hành vi người dùng, từ đó gợi ý các Voucher phù hợp nhất (Personalized Recommendations).
- Phân tích dữ liệu lớn (Big Data) để cung cấp báo cáo chuyên sâu (Premium Data Insights) cho các chuỗi cửa hàng lớn.

## 5. Thanh toán Điện tử (Payment Integration)
- Tích hợp cổng thanh toán (VNPay, MoMo, ZaloPay, Apple Pay) ngay bên trong ứng dụng, biến TingTing thành một siêu ví thực thụ vừa thanh toán vừa tích điểm trong 1 chạm.
