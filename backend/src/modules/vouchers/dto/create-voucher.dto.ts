/**
 * @file        create-voucher.dto.ts
 * @module      VouchersModule
 * @description DTO cho request tạo Voucher mới bởi Merchant.
 *
 * @responsibility
 *   - Validate toàn bộ thông tin voucher trước khi lưu DB
 *
 * @dependencies
 *   - class-validator
 *   - class-transformer
 *
 * @todo
 *   - [ ] Thêm trường image_url khi tích hợp upload ảnh (Task tương lai)
 */

import {
  IsNotEmpty,
  IsString,
  IsInt,
  IsPositive,
  Min,
  IsDateString,
  MaxLength,
  IsOptional,
} from "class-validator";
import { Type } from "class-transformer";

export class CreateVoucherDto {
  @IsNotEmpty({ message: "Tiêu đề voucher không được để trống" })
  @IsString()
  @MaxLength(255, { message: "Tiêu đề tối đa 255 ký tự" })
  title: string;

  @IsOptional()
  @IsString()
  description?: string;

  /**
   * Số điểm cần để đổi voucher này.
   * Merchant tự nhập — không có giới hạn cứng từ hệ thống.
   */
  @IsNotEmpty({ message: "Số điểm cần đổi không được để trống" })
  @IsInt({ message: "Số điểm phải là số nguyên" })
  @IsPositive({ message: "Số điểm phải lớn hơn 0" })
  @Type(() => Number)
  points_cost: number;

  @IsNotEmpty({ message: "Số lượng phát hành không được để trống" })
  @IsInt({ message: "Số lượng phải là số nguyên" })
  @Min(1, { message: "Số lượng tối thiểu là 1" })
  @Type(() => Number)
  total_quantity: number;

  /**
   * Thời gian hết hạn của voucher (ISO 8601 string).
   * Ví dụ: "2026-12-31T23:59:59.000Z"
   */
  @IsNotEmpty({ message: "Thời gian hết hạn không được để trống" })
  @IsDateString(
    {},
    { message: "Thời gian hết hạn phải đúng định dạng ISO 8601" },
  )
  expired_at: string;
}
