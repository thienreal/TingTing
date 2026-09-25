/**
 * @file        earn-points.dto.ts
 * @module      UsersModule
 * @description DTO cho request cộng điểm của Merchant sau khi khách thanh toán.
 *
 * @responsibility
 *   - Validate UUID của user và số tiền hóa đơn đầu vào
 *
 * @dependencies
 *   - class-validator
 *
 * @todo
 *   - [ ] Thêm trường merchant_note (ghi chú nội bộ) khi cần audit
 */

import { IsNotEmpty, IsUUID, IsNumber, IsPositive, Min } from "class-validator";

export class EarnPointsDto {
  /**
   * UUID của người dùng được cộng điểm.
   * Lấy từ mã QR định danh động do User App hiển thị.
   */
  @IsNotEmpty({ message: "user_id không được để trống" })
  @IsUUID("4", { message: "user_id không hợp lệ" })
  user_id: string;

  /**
   * Số tiền hóa đơn (VND).
   * Điểm được tính theo công thức: floor(bill_amount / POINTS_RATIO).
   * POINTS_RATIO đọc từ biến môi trường (mặc định 1000: mỗi 1.000đ = 1 điểm).
   */
  @IsNotEmpty({ message: "Số tiền hóa đơn không được để trống" })
  @IsNumber({}, { message: "Số tiền hóa đơn phải là số" })
  @IsPositive({ message: "Số tiền hóa đơn phải lớn hơn 0" })
  @Min(1000, { message: "Số tiền hóa đơn tối thiểu là 1.000đ" })
  bill_amount: number;
}
