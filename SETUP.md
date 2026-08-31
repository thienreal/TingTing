# Hướng Dẫn Cài Đặt Môi Trường - TingTing

> Làm theo đúng thứ tự từng bước dưới đây. Bỏ qua bất kỳ bước nào cũng có thể gây lỗi.

---

## Yêu Cầu Phần Mềm (Cài trước khi làm bất cứ điều gì)

| Phần mềm | Phiên bản khuyên dùng | Link tải |
|---|---|---|
| Node.js | >= 20.x (LTS) | https://nodejs.org |
| npm | >= 10.x (đi kèm Node.js) | (tự động) |
| Docker | Mới nhất | https://www.docker.com/products/docker-desktop |
| Flutter SDK | >= 3.x (stable) | https://docs.flutter.dev/get-started/install |
| Git | Mới nhất | https://git-scm.com |
| NestJS CLI | >= 10.x | `npm install -g @nestjs/cli` |

> **Kiểm tra sau khi cài:** Chạy các lệnh sau trong terminal để xác nhận đã cài đúng:
> ```bash
> node -v
> npm -v
> docker --version
> docker-compose --version
> flutter --version
> git --version
> nest --version
> ```

---

## Bước 1: Clone Dự Án

```bash
git clone <repository-url> TingTing
cd TingTing
```

---

## Bước 2: Cài Đặt Backend (NestJS)

### 2.1 Di chuyển vào thư mục backend

```bash
cd backend
```

### 2.2 Cài đặt toàn bộ thư viện Node.js

```bash
npm install
```

### 2.3 Cấu hình biến môi trường

Sao chép file mẫu và điền thông tin thực tế của máy bạn:

```bash
cp .env.example .env
```

Sau đó mở file `.env` và thiết lập biến môi trường. Vì chúng ta dùng Docker cho Database, phần DB cứ giữ nguyên cấu hình mặc định (hoặc đổi password tùy ý). Ví dụ:

```env
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres  # Phải khớp với POSTGRES_USER
DB_PASSWORD=your_password  # Phải khớp với POSTGRES_PASSWORD
DB_NAME=tingting_db   # Phải khớp với POSTGRES_DB

POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_password
POSTGRES_DB=tingting_db

TYPEORM_SYNC=true     # Cho phép TypeORM tự động tạo bảng (chỉ dùng trong môi trường dev)
JWT_SECRET=           # Thay bằng 1 chuỗi bí mật, càng dài càng tốt
```

### 2.4 Khởi động Database (Bằng Docker)

Trở lại thư mục gốc của dự án (nơi có file `docker-compose.yml`) và chạy lệnh sau để khởi động PostgreSQL và pgAdmin:

```bash
cd ..
docker-compose up -d
```

> **Lưu ý:** 
> - Docker sẽ tự động tạo database `tingting_db` thông qua file cấu hình `docker/init.sql`. Bạn không cần cài đặt hay thao tác PostgreSQL thủ công.
> - Chờ khoảng 5-10s cho DB khởi tạo. Sau đó quay lại thư mục backend để chạy server ở bước tiếp theo: 
> ```bash
> cd backend
> ```

### 2.5 Chạy Backend Server

```bash
# Chạy ở chế độ dev (tự động reload khi sửa code)
npm run start:dev

# Server sẽ chạy tại: http://localhost:3000
# WebSocket sẽ chạy tại: ws://localhost:3001
```

---

## Bước 3: Cài Đặt Mobile App - User App (Flutter)

### 3.1 Di chuyển vào thư mục app_user

```bash
cd ../app_user
```

### 3.2 Tải các thư viện Flutter

```bash
flutter pub get
```

### 3.3 Cấu hình địa chỉ Backend

Mở file cấu hình API (ví dụ: `lib/core/api_client.dart`) và chỉnh sửa `BASE_URL` trỏ về đúng IP máy chạy Backend:

```dart
// Nếu chạy trên Android Emulator:
const String baseUrl = 'http://10.0.2.2:3000';

// Nếu chạy trên thiết bị thật (thay bằng IP máy tính của bạn trên mạng LAN):
const String baseUrl = 'http://192.168.x.x:3000';

// Nếu chạy trên iOS Simulator:
const String baseUrl = 'http://localhost:3000';
```

### 3.4 Chạy User App

```bash
# Xem danh sách thiết bị đang kết nối
flutter devices

# Chạy app (thay <device-id> bằng ID thiết bị từ lệnh trên)
flutter run -d <device-id>
```

---

## Bước 4: Cài Đặt Mobile App - Merchant App (Flutter)

Thực hiện tương tự Bước 3 nhưng trong thư mục `app_merchant/`:

```bash
cd ../app_merchant
flutter pub get
# Chỉnh sửa cấu hình kết nối API tương tự
flutter run -d <device-id>
```

---

## Gỡ Lỗi Thường Gặp

**Lỗi: `relation "users" does not exist`**
- Nguyên nhân: TypeORM chưa tạo bảng.
- Giải pháp: Kiểm tra biến `TYPEORM_SYNC=true` trong file `.env` của backend.

**Lỗi: `password authentication failed for user "postgres"`**
- Nguyên nhân: Sai mật khẩu PostgreSQL trong file `.env`.
- Giải pháp: Kiểm tra lại `DB_PASSWORD` trong `backend/.env`.

**Lỗi Flutter: `SocketException: Connection refused`**
- Nguyên nhân: Backend chưa chạy hoặc sai địa chỉ IP.
- Giải pháp: Đảm bảo `npm run start:dev` đang chạy và kiểm tra lại địa chỉ kết nối trong app.

**Lỗi: `nest: command not found`**
- Nguyên nhân: NestJS CLI chưa được cài globally.
- Giải pháp: `npm install -g @nestjs/cli`
