/**
 * @file        auth.controller.ts
 * @module      AuthModule
 * @description Controller định nghĩa các route xác thực của TingTing API.
 *   Expose 3 endpoints: gửi OTP, xác thực OTP (User), đăng nhập (Merchant).
 *
 * @responsibility
 *   - Nhận request HTTP, validate DTO, uỷ thác xử lý cho AuthService
 *   - Trả về response chuẩn với status code phù hợp
 *
 * @dependencies
 *   - AuthService
 *   - class-validator (ValidationPipe được bật global trong main.ts)
 *
 * @todo
 *   - [ ] Thêm endpoint POST /auth/refresh để đổi Refresh Token
 *   - [ ] Thêm endpoint POST /auth/logout (blacklist token)
 *   - [ ] Thêm Swagger @ApiTags, @ApiOperation decorators khi tích hợp docs
 */

import { Controller, Post, Body, HttpCode, HttpStatus } from "@nestjs/common";
import { AuthService } from "./auth.service";
import { SendOtpDto } from "./dto/send-otp.dto";
import { VerifyOtpDto } from "./dto/verify-otp.dto";
import { MerchantLoginDto } from "./dto/merchant-login.dto";

@Controller("auth")
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  // ==========================================
  // POST /auth/send-otp
  // ==========================================

  /**
   * Nhận số điện thoại và gửi OTP.
   *
   * @mvp Không gửi SMS thật — Mock OTP luôn là "000000".
   *       Xem Future_Development.md §1 để biết kế hoạch thay thế.
   *
   * @body phone_number - Số điện thoại Việt Nam (0[3|5|7|8|9]xxxxxxxx)
   * @returns 200 + message xác nhận
   */
  @Post("send-otp")
  @HttpCode(HttpStatus.OK)
  sendOtp(@Body() dto: SendOtpDto) {
    return this.authService.sendOtp(dto);
  }

  // ==========================================
  // POST /auth/verify-otp
  // ==========================================

  /**
   * Xác thực OTP và đăng nhập User.
   * Tự động tạo tài khoản User mới nếu số điện thoại chưa đăng ký.
   *
   * @mvp OTP hợp lệ duy nhất là "000000".
   *       Xem Future_Development.md §1 để biết kế hoạch thay thế.
   *
   * @body phone_number, otp
   * @returns 200 + { access_token, user, is_new_user }
   */
  @Post("verify-otp")
  @HttpCode(HttpStatus.OK)
  verifyOtp(@Body() dto: VerifyOtpDto) {
    return this.authService.verifyOtp(dto);
  }

  // ==========================================
  // POST /auth/merchant/login
  // ==========================================

  /**
   * Đăng nhập cho Merchant bằng email/password.
   *
   * @body email, password
   * @returns 200 + { access_token, merchant }
   */
  @Post("merchant/login")
  @HttpCode(HttpStatus.OK)
  merchantLogin(@Body() dto: MerchantLoginDto) {
    return this.authService.merchantLogin(dto);
  }
}
