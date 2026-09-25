/**
 * @file        users.controller.ts
 * @module      UsersModule
 * @description Controller định nghĩa các route Users & Points của TingTing API.
 *
 * @responsibility
 *   - GET /users/me           → Thông tin profile User (User only)
 *   - GET /users/me/transactions → Lịch sử giao dịch (User only)
 *   - POST /points/earn       → Cộng điểm sau giao dịch (Merchant only)
 *   - GET /points/balance     → Số dư điểm (User only)
 *
 * @dependencies
 *   - UsersService
 *   - JwtAuthGuard, RolesGuard (từ AuthModule)
 *   - @Roles, @CurrentUser decorators
 *
 * @todo
 *   - [ ] Thêm endpoint PUT /users/me để User cập nhật full_name
 *   - [ ] Thêm phân trang (pagination) cho GET /users/me/transactions
 */

import {
  Controller,
  Get,
  Post,
  Body,
  UseGuards,
  HttpCode,
  HttpStatus,
} from "@nestjs/common";
import { UsersService } from "./users.service";
import { EarnPointsDto } from "./dto/earn-points.dto";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";
import { RolesGuard } from "../auth/guards/roles.guard";
import { Roles } from "../auth/decorators/roles.decorator";
import { CurrentUser } from "../auth/decorators/current-user.decorator";

@Controller()
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  // ==========================================
  // GET /users/me
  // ==========================================

  /**
   * Trả về thông tin profile của User đang đăng nhập.
   * Yêu cầu: JWT hợp lệ với role USER.
   */
  @Get("users/me")
  @Roles("USER")
  @UseGuards(JwtAuthGuard, RolesGuard)
  getMe(@CurrentUser() currentUser: { userId: string }) {
    return this.usersService.getMe(currentUser.userId);
  }

  // ==========================================
  // GET /users/me/transactions
  // ==========================================

  /**
   * Trả về lịch sử giao dịch (tích điểm, đổi điểm) của User.
   * Kết quả sắp xếp theo thời gian mới nhất trước.
   * Yêu cầu: JWT hợp lệ với role USER.
   */
  @Get("users/me/transactions")
  @Roles("USER")
  @UseGuards(JwtAuthGuard, RolesGuard)
  getMyTransactions(@CurrentUser() currentUser: { userId: string }) {
    return this.usersService.getMyTransactions(currentUser.userId);
  }

  // ==========================================
  // POST /points/earn (Merchant only)
  // ==========================================

  /**
   * Merchant cộng điểm cho User sau khi khách thanh toán.
   * Điểm tính theo POINTS_RATIO từ config (mặc định: 1.000đ = 1 điểm).
   * Dùng Row-Level Lock chống race condition.
   * Yêu cầu: JWT hợp lệ với role MERCHANT.
   *
   * @body user_id  - UUID của khách hàng (quét từ QR)
   * @body bill_amount - Số tiền hóa đơn (VND)
   */
  @Post("points/earn")
  @Roles("MERCHANT")
  @UseGuards(JwtAuthGuard, RolesGuard)
  @HttpCode(HttpStatus.OK)
  earnPoints(
    @CurrentUser() currentUser: { userId: string },
    @Body() dto: EarnPointsDto,
  ) {
    return this.usersService.earnPoints(currentUser.userId, dto);
  }

  // ==========================================
  // GET /points/balance (User only)
  // ==========================================

  /**
   * Trả về số dư điểm và hạng thành viên hiện tại của User.
   * Yêu cầu: JWT hợp lệ với role USER.
   */
  @Get("points/balance")
  @Roles("USER")
  @UseGuards(JwtAuthGuard, RolesGuard)
  getPointsBalance(@CurrentUser() currentUser: { userId: string }) {
    return this.usersService.getPointsBalance(currentUser.userId);
  }
}
