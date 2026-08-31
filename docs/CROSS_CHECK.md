# Checklist Kiểm Tra Khi Chỉnh Sửa Code - TingTing

> AI đọc file này sau mỗi lần sinh hoặc sửa code để đảm bảo toàn bộ hệ thống được cập nhật đồng bộ.
> Việc sửa code không bao giờ đứng độc lập — code, tài liệu, cấu hình và hạ tầng phải luôn nhất quán với nhau.

---

## Nhóm 1 — Bắt Buộc (Không có ngoại lệ)

- [ ] **`docs/task_tracker.md`** — Tick `[x]` cho task vừa hoàn thành.
- [ ] **`docs/AI_Notes.md`** — Ghi log chi tiết: ngày giờ, việc đã làm, lý do, thông số kỹ thuật.

---

## Nhóm 2 — Cấu Hình & Môi Trường

Cân nhắc cập nhật khi code mới liên quan đến:

- [ ] **`backend/.env` & `backend/.env.example`** — Thêm biến môi trường mới nếu code cần đọc thêm config (API key, port, timeout...).
- [ ] **`backend/package.json`** — Thêm dependency mới nếu `npm install xyz` được dùng.
- [ ] **`docker-compose.yml`** — Thêm service mới (Redis, MinIO...) hoặc thay đổi port/volume.
- [ ] **`docker/init.sql`** — Thêm extension PostgreSQL mới nếu cần (vd: `pg_trgm`).
- [ ] **`backend/src/config/database.config.ts`** — Cập nhật path entities/migrations nếu thêm module mới.

---

## Nhóm 3 — Tài Liệu Định Hướng

Cân nhắc cập nhật khi code thay đổi cấu trúc hoặc quy trình:

- [ ] **`docs/DEVELOPER_GUIDE.md`** — Thêm lệnh CLI mới, thư mục mới, thay đổi quy ước làm việc.
- [ ] **`docs/SETUP.md`** — Nếu yêu cầu cài đặt ban đầu thay đổi (phần mềm mới, bước mới).
- [ ] **`docs/Architecture.md`** — Nếu thay đổi luồng nghiệp vụ hoặc Tech Stack cốt lõi.

---

## Nhóm 4 — Giao Diện (CHỈ khi code Mobile/Flutter)

- [ ] **`docs/UI_Design_Rules.md`** — Đọc lại trước khi code bất kỳ màn hình nào.
- [ ] **`app_user/lib/core/theme.dart`** & **`app_merchant/lib/core/theme.dart`** — Đưa màu/kích thước mới vào đây, tuyệt đối không hardcode trực tiếp vào file UI.

---

> **Kỷ luật:** Bất kỳ sự thiếu đồng bộ nào giữa Code và Tài liệu/Cấu hình đều bị coi là AI chưa hoàn thành nhiệm vụ.
