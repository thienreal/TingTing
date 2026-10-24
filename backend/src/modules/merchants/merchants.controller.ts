/**
 * @file        merchants.controller.ts
 * @module      MerchantsModule
 * @description Controller định nghĩa các route cho Merchant.
 *
 * @responsibility
 *   - GET /merchants/me/report -> Xem báo cáo thống kê
 *
 * @dependencies
 *   - MerchantsService
 *   - JwtAuthGuard, RolesGuard (AuthModule)
 */

import { Controller, Get, UseGuards } from "@nestjs/common";
import { MerchantsService } from "./merchants.service";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";
import { RolesGuard } from "../auth/guards/roles.guard";
import { Roles } from "../auth/decorators/roles.decorator";
import { CurrentUser } from "../auth/decorators/current-user.decorator";

@Controller("merchants")
export class MerchantsController {
  constructor(private readonly merchantsService: MerchantsService) {}

  // ==========================================
  // GET /merchants (Public / Merchant / User)
  // ==========================================

  /**
   * Lấy danh sách toàn bộ đối tác trong mạng lưới liên minh TingTing.
   * Dùng cho dropdown liên kết đối tác và hiển thị danh mục.
   */
  @Get()
  getMerchants() {
    return this.merchantsService.findAllActiveMerchants();
  }

  // ==========================================
  // GET /merchants/me/report (Merchant only)
  // ==========================================

  /**
   * Lấy báo cáo thống kê tổng quan của cửa hàng.
   * Yêu cầu: JWT hợp lệ với role MERCHANT.
   */
  @Get("me/report")
  @Roles("MERCHANT")
  @UseGuards(JwtAuthGuard, RolesGuard)
  getReport(@CurrentUser() currentUser: { userId: string }) {
    return this.merchantsService.getReport(currentUser.userId);
  }

  // ==========================================
  // GET /merchants/me/transactions (Merchant only)
  // ==========================================

  /**
   * Lấy danh sách 30 giao dịch gần nhất của cửa hàng.
   * Yêu cầu: JWT hợp lệ với role MERCHANT.
   */
  @Get("me/transactions")
  @Roles("MERCHANT")
  @UseGuards(JwtAuthGuard, RolesGuard)
  getTransactions(@CurrentUser() currentUser: { userId: string }) {
    return this.merchantsService.getTransactions(currentUser.userId);
  }
}
