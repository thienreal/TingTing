# Tiêu Chuẩn Viết Code - TingTing

> AI đọc file này khi bắt đầu tạo hoặc chỉnh sửa bất kỳ file code nào (`.ts` hoặc `.dart`).

---

## 1. Phần Tiêu Đề Bắt Buộc Ở Đầu Mỗi File

**Mẫu TypeScript (NestJS Backend):**
```typescript
/**
 * @file        tên-file.ts
 * @module      Tên Module (vd: UsersModule)
 * @description Mô tả ngắn gọn file này làm gì (1-2 câu).
 *
 * @responsibility
 *   - Trách nhiệm 1 của file này
 *   - Trách nhiệm 2 của file này
 *
 * @dependencies
 *   - Thư viện hoặc module bên ngoài quan trọng (nếu có)
 *
 * @todo
 *   - [ ] Tính năng hoặc phần logic còn thiếu cần bổ sung
 *   - [ ] Vấn đề cần sửa hoặc cải thiện trong tương lai
 *   (Để trống nếu file đã hoàn thiện)
 */
```

**Mẫu Dart (Flutter):**
```dart
/// File: tên-file.dart
/// Module: Tên feature (vd: AuthFeature)
/// Description: Mô tả ngắn gọn file này làm gì (1-2 câu).
///
/// Responsibility:
///   - Trách nhiệm 1
///   - Trách nhiệm 2
///
/// Dependencies:
///   - Package hoặc widget phụ thuộc quan trọng (nếu có)
///
/// Todo:
///   - [ ] Tính năng hoặc phần UI còn thiếu cần bổ sung
///   - [ ] Vấn đề cần sửa hoặc cải thiện trong tương lai
///   (Để trống nếu file đã hoàn thiện)
```

---

## 2. Quy Tắc Viết Comment Trong Code

**Nguyên tắc cốt lõi:** Comment phải giải thích **TẠI SAO** (why), không chỉ **LÀM GÌ** (what).

### 2.1 Comment trước mỗi hàm/method có logic nghiệp vụ

```typescript
/**
 * Cộng điểm cho người dùng sau khi giao dịch tại cửa hàng.
 * Sử dụng PostgreSQL Row-Level Lock để tránh race condition.
 *
 * @param userId     - UUID của người dùng được cộng điểm
 * @param billAmount - Số tiền hóa đơn (VND), dùng để tính điểm
 * @param merchantId - UUID của cửa hàng thực hiện giao dịch
 * @returns          Số điểm vừa được cộng thêm
 * @throws           NotFoundException nếu user hoặc merchant không tồn tại
 */
async earnPoints(userId: string, billAmount: number, merchantId: string): Promise<number> {
```

### 2.2 Comment giải thích logic phức tạp

```typescript
// Dùng SELECT ... FOR UPDATE để khóa dòng dữ liệu user trong transaction.
// Ngăn 2 request đồng thời trừ điểm cùng lúc gây sai số (double-spending).
const user = await queryRunner.manager.findOne(User, {
  where: { id: userId },
  lock: { mode: 'pessimistic_write' },
});
```

### 2.3 Comment phân vùng (Section Comment)

```typescript
// ==========================================
// KHỞI TẠO & CẤU HÌNH
// ==========================================

// ==========================================
// XỬ LÝ NGHIỆP VỤ CHÍNH
// ==========================================

// ==========================================
// XỬ LÝ LỖI & ROLLBACK
// ==========================================
```

### 2.4 KHÔNG viết comment thừa

```typescript
// Xấu — code đã tự nói rõ
const total = a + b; // Cộng a và b

// Tốt — giải thích tại sao
// Chia 1000 để chuyển từ đồng sang nghìn đồng theo chuẩn hiển thị UI
const displayAmount = amount / 1000;
```

### 2.5 TODO và FIXME

```typescript
// TODO: Thêm cache Redis để tránh query DB liên tục
// FIXME: Cần xử lý edge case khi voucher hết hạn đúng lúc user đang đổi
```
