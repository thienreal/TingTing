/**
 * @file        use-voucher.dto.ts
 * @module      VouchersModule
 * @description DTO cho request Merchant xác nhận sử dụng voucher của khách.
 *
 * @responsibility
 *   - Validate user_voucher_id (UUID) truyền lên khi Merchant quét barcode
 *
 * @dependencies
 *   - class-validator
 *
 * @todo
 *   - [ ] (Không cần thêm gì)
 */

import { IsNotEmpty, IsUUID } from "class-validator";

export class UseVoucherDto {
  /**
   * UUID của bản ghi UserVoucher (KHÔNG phải Voucher ID).
   * Merchant quét barcode từ màn hình "My Vouchers" của User App
   * để lấy giá trị này.
   */
  @IsNotEmpty({ message: "user_voucher_id không được để trống" })
  @IsUUID("4", { message: "user_voucher_id không hợp lệ" })
  user_voucher_id: string;
}
