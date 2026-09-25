/**
 * @file        merchant-login.dto.ts
 * @module      AuthModule
 * @description DTO cho request đăng nhập của Merchant bằng email/password.
 *
 * @responsibility
 *   - Validate email và mật khẩu đầu vào
 *
 * @dependencies
 *   - class-validator
 *
 * @todo
 *   - [ ] Thêm field refresh_token khi triển khai cơ chế Refresh Token
 */

import { IsEmail, IsNotEmpty, IsString, MinLength } from "class-validator";

export class MerchantLoginDto {
  @IsNotEmpty({ message: "Email không được để trống" })
  @IsEmail({}, { message: "Email không hợp lệ" })
  email: string;

  @IsNotEmpty({ message: "Mật khẩu không được để trống" })
  @IsString()
  @MinLength(6, { message: "Mật khẩu phải có ít nhất 6 ký tự" })
  password: string;
}
