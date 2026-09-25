/**
 * @file        send-otp.dto.ts
 * @module      AuthModule
 * @description DTO cho request gửi OTP đến số điện thoại người dùng.
 *
 * @responsibility
 *   - Validate định dạng số điện thoại trước khi xử lý
 *
 * @dependencies
 *   - class-validator
 *
 * @todo
 *   - [ ] Giới hạn rate-limit (tối đa 5 lần/phút) khi tích hợp SMS thật
 */

import { IsNotEmpty, IsString, Matches } from "class-validator";

export class SendOtpDto {
  /**
   * Số điện thoại Việt Nam, bắt đầu bằng 0, 10-11 chữ số.
   * Ví dụ: "0901234567"
   */
  @IsNotEmpty({ message: "Số điện thoại không được để trống" })
  @IsString()
  @Matches(/^(0[3|5|7|8|9])+([0-9]{8})$/, {
    message: "Số điện thoại không hợp lệ (phải là số điện thoại Việt Nam)",
  })
  phone_number: string;
}
