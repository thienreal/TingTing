# Hướng dẫn bắt buộc dành cho AI (AI Agent Instructions)

> **QUAN TRỌNG:** Đọc và tuân thủ file này trước khi làm bất kỳ việc gì trong dự án.

---

## 1. Bối Cảnh Dự Án

Dự án **TingTing** — "Nền tảng tích hợp ví điểm thưởng tập trung" (đọc thêm tại `README.md` và `docs/Architecture.md`).

**Tech Stack cố định — không được tự ý thay đổi:**
| Thành phần | Công nghệ |
|---|---|
| Mobile App | Flutter (cả User App và Merchant App) |
| Backend Framework | NestJS (TypeScript) |
| ORM | TypeORM — không dùng Prisma |
| Database | PostgreSQL |
| Real-time | WebSocket (Socket.IO) — không dùng Firebase FCM |

---

## 2. Quy Tắc Giao Diện

- Chỉ khi làm task liên quan đến UI/Flutter mới được đọc `docs/UI_Design_Rules.md`.
- Tuyệt đối không hardcode màu sắc hay kích thước — phải lấy từ `theme.dart`.

---

## 3. Quy Tắc Cấu Hình & Môi Trường

- Tuyệt đối không hardcode bất kỳ giá trị nào có thể thay đổi (URL, port, key, secret...).
- Mọi config phải đọc từ `backend/.env`. Mỗi biến mới phải ghi ngay vào `backend/.env.example`.

---

## 4. Quy Tắc Sau Khi Hoàn Thành Task

Mỗi khi hoàn thành một task, thực hiện **đồng thời 2 việc sau** trước khi kết thúc phản hồi:

1. Mở `docs/task_tracker.md` → đổi trạng thái task vừa làm thành `[x]`.
2. Mở `docs/AI_Notes.md` → ghi log theo đúng định dạng (ngày giờ, việc đã làm, lý do, thông số kỹ thuật).

---

## 5. Quy Tắc Cập Nhật Tài Liệu Lập Trình Viên

Mỗi khi thay đổi các thứ sau, phải cập nhật `docs/DEVELOPER_GUIDE.md`:
- Thêm biến môi trường → cập nhật bảng Mục 4.
- Thêm lệnh CLI mới → cập nhật Mục 5.
- Thêm thư viện cốt lõi → cập nhật bảng Mục 1.
- Thêm file/thư mục quan trọng → cập nhật Mục 3.

---

## 6. Quy Tắc Viết Code

Khi bắt đầu tạo hoặc sửa bất kỳ file code nào, đọc **`docs/CODE_STANDARDS.md`** và tuân theo.

Gồm: tiêu đề đầu file (bắt buộc), chuẩn comment JSDoc/DartDoc, section comment, và quy tắc `@todo`.

---

## 7. Quy Tắc Cập Nhật Hạ Tầng

Cập nhật các file tương ứng khi:
- Thêm service mới → `docker-compose.yml`
- Thêm npm package → `backend/package.json`
- Thêm PostgreSQL extension → `docker/init.sql`

---

## 8. Kiểm Tra Toàn Diện Sau Khi Code

Sau khi viết hoặc sửa code, đọc **`docs/CROSS_CHECK.md`** và rà soát toàn bộ checklist trước khi kết thúc phản hồi. Đây là bước đảm bảo code, tài liệu, cấu hình và hạ tầng luôn đồng bộ nhau.
