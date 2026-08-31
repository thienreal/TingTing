# Quy tắc Thiết kế Giao diện Chuyên Sâu (Strict UI/UX Guidelines)
Khi AI hỗ trợ viết code giao diện Flutter, **BẮT BUỘC** phải tái tạo chính xác 100% phong cách từ các file ảnh mẫu trong `../anh/`. Các thông số dưới đây là tiêu chuẩn bắt buộc:

### 🔹 Mã màu (Color Palette):
- **Primary Brand Color (Vàng):** `#FAD240` (Sử dụng cho Header, Background nổi bật, Icon Đồng xu VUI).
- **Primary Action Button (Hồng/Đỏ san hô):** `#E8687D` (Sử dụng cho nút "Đổi ngay", "Tiếp tục", và các đường gạch dưới Tab đang chọn).
- **Background App (Xám nhạt):** `#F4F5F6` (Màu nền của app, giúp làm nổi bật các Card màu trắng).
- **Card Background (Trắng):** `#FFFFFF` (Nền của các danh sách ưu đãi, form nhập liệu).
- **Text Primary (Đen/Xám đậm):** `#1A1A1A` (Dành cho Tiêu đề lớn, Tên voucher).
- **Text Secondary (Xám nhạt):** `#757575` (Dành cho Mô tả, Hạn sử dụng, Text phụ).

### 🔹 Typography (Kiểu chữ):
- Sử dụng phông chữ hình học (Geometric Sans-serif) mang cảm giác hiện đại như `Be Vietnam Pro`, `Montserrat`, hoặc `Inter`.
- **Headings (Tiêu đề):** Font-weight `Bold` (700) hoặc `ExtraBold` (800).
- **Buttons (Nút bấm):** Font-weight `SemiBold` (600), chữ trắng.
- **Body text:** Font-weight `Regular` (400) hoặc `Medium` (500).

### 🔹 Shapes & Layout (Hình khối & Bố cục):
- **Border Radius (Góc bo tròn):**
  - **Cards (Thẻ ưu đãi):** `16px`.
  - **Buttons (Nút bấm):** `12px` (hoặc bo tròn hoàn toàn dạng Pill `50px` đối với thanh Tìm kiếm).
  - **Voucher Ticket (Thẻ Voucher đặc biệt):** Cần dùng CustomClipper hoặc Container đặc biệt để tạo vết cắt hình bán nguyệt (ticket notch) ở 2 cạnh bên.
- **Padding/Margin:** Khoảng cách tiêu chuẩn giữa các khối (block) là `16px` hoặc `24px` để tạo cảm giác "thoáng" (Clean UI).

### 🔹 UI Components (Thành phần giao diện):
- **Bottom Navigation Bar:** Nền trắng, sử dụng các Icon dạng Outline mỏng. Tab đang Active sẽ có icon đậm hơn hoặc màu đen tuyền kèm chữ in đậm.
- **Tabs (Đang có, Đã dùng, ...):** Tab đang Active phải có đường gạch chân mỏng màu Hồng/Đỏ san hô (`#E8687D`).
- **Nút Call-to-Action (Đổi ngay, Tiếp tục):** Luôn trải dài toàn màn hình (margin ngang 16px) và neo ở cạnh dưới màn hình (Bottom fixed).
- **Shadows (Đổ bóng):** Đổ bóng cực kỳ nhạt và mềm cho các Card màu trắng để tạo hiệu ứng nổi (Elevated): `BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))`.

### 🔹 Quy trình làm việc của AI về UI
- Bất cứ khi nào tạo ra một component UI mới, AI phải tự động đối chiếu xem thiết kế đó có khớp với định hướng "Trẻ trung, Bo tròn, Dùng màu Vàng/Hồng làm điểm nhấn" hay chưa.
- Khi được yêu cầu tái tạo một màn hình, AI cần chủ động dùng tool `view_file` để quét lại các bức ảnh trong thư mục `../anh/` nhằm lấy mã màu và kích thước chi tiết trước khi code.
