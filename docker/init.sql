-- ============================================================
-- init.sql — Script khởi tạo database TingTing
-- ============================================================
-- File này được PostgreSQL Docker tự động chạy 1 lần duy nhất
-- khi container được tạo lần đầu tiên (không chạy lại nếu đã có dữ liệu).
--
-- Mục đích:
--   - Kích hoạt extension uuid-ossp để sinh UUID cho primary key
-- ============================================================

-- Kích hoạt extension sinh UUID (bắt buộc vì Entity dùng @PrimaryGeneratedColumn('uuid'))
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Thông báo xác nhận
SELECT 'TingTing database initialized successfully.' AS status;
