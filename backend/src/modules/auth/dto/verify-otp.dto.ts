/**
 * @file        verify-otp.dto.ts
 * @module      AuthModule
 * @description DTO cho request xác thực OTP và đăng nhập User.
 *
 * @responsibility
 *   - Validate số điện thoại và mã OTP đầu vào
 *
 * @dependencies
 *   - class-validator
 *
 * @todo
 *   - [ ] Thêm trường device_token khi tích hợp Push Notification thật
 */

import { IsNotEmpty, IsString, Length, Matches } from "class-validator";

export class VerifyOtpDto {
  @IsNotEmpty({ message: "Số điện thoại không được để trống" })
  @IsString()
  @Matches(/^(0[3|5|7|8|9])+([0-9]{8})$/, {
    message: "Số điện thoại không hợp lệ",
  })
  phone_number: string;

  /**
   * Mã OTP gồm đúng 6 chữ số.
   *
   * @mvp Mock OTP cố định là "000000" cho toàn bộ Giai đoạn 1 (MVP).
   * Xem Future_Development.md §1 — Tích hợp SMS OTP Thực tế để biết
   * kế hoạch thay thế bằng Twilio / ESMS.vn trong Giai đoạn 2.
   */
  @IsNotEmpty({ message: "Mã OTP không được để trống" })
  @IsString()
  @Length(6, 6, { message: "Mã OTP phải gồm đúng 6 chữ số" })
  otp: string;
}
