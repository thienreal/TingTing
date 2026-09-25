/**
 * @file        vouchers.controller.ts
 * @module      VouchersModule
 * @description Controller định nghĩa các route Vouchers của TingTing API.
 *
 * @responsibility
 *   - GET  /vouchers              → Danh sách voucher còn hiệu lực (User)
 *   - GET  /vouchers/mine         → Voucher User đang sở hữu (User)
 *   - GET  /vouchers/:id          → Chi tiết một voucher (User)
 *   - POST /vouchers/:id/redeem   → Đổi điểm lấy voucher - chống double-spending (User)
 *   - POST /merchants/vouchers    → Tạo voucher mới (Merchant)
 *   - POST /points/use-voucher    → Xác nhận dùng voucher khi khách quét (Merchant)
 *
 * @dependencies
 *   - VouchersService
 *   - JwtAuthGuard, RolesGuard (từ AuthModule)
 *
 * @todo
 *   - [ ] Thêm phân trang (pagination) cho GET /vouchers khi có nhiều merchant
 *   - [ ] Thêm filter theo danh mục merchant (category)
 */

import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  ParseUUIDPipe,
  UseGuards,
  HttpCode,
  HttpStatus,
} from "@nestjs/common";
import { VouchersService } from "./vouchers.service";
import { CreateVoucherDto } from "./dto/create-voucher.dto";
import { UseVoucherDto } from "./dto/use-voucher.dto";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";
import { RolesGuard } from "../auth/guards/roles.guard";
import { Roles } from "../auth/decorators/roles.decorator";
import { CurrentUser } from "../auth/decorators/current-user.decorator";

@Controller()
export class VouchersController {
  constructor(private readonly vouchersService: VouchersService) {}

  // ==========================================
  // GET /vouchers  (User)
  // ==========================================

  /**
   * Lấy danh sách toàn bộ Voucher còn hiệu lực, còn tồn kho.
   * Kèm tên cửa hàng phát hành.
   */
  @Get("vouchers")
  @Roles("USER")
  @UseGuards(JwtAuthGuard, RolesGuard)
  findAll() {
    return this.vouchersService.findAll();
  }

  // ==========================================
  // GET /vouchers/mine  (User)
  // Khai báo TRƯỚC /:id để tránh "mine" bị hiểu là UUID param
  // ==========================================

  /**
   * Lấy danh sách Voucher User đã đổi (bao gồm ACTIVE, USED, EXPIRED).
   * Dùng để hiển thị màn hình "Voucher của tôi" trong app.
   */
  @Get("vouchers/mine")
  @Roles("USER")
  @UseGuards(JwtAuthGuard, RolesGuard)
  findMyVouchers(@CurrentUser() currentUser: { userId: string }) {
    return this.vouchersService.findMyVouchers(currentUser.userId);
  }

  // ==========================================
  // GET /vouchers/:id  (User)
  // ==========================================

  /**
   * Lấy chi tiết một Voucher theo UUID.
   * Dùng ParseUUIDPipe để validate tự động, trả 400 nếu id không phải UUID.
   */
  @Get("vouchers/:id")
  @Roles("USER")
  @UseGuards(JwtAuthGuard, RolesGuard)
  findOne(@Param("id", ParseUUIDPipe) id: string) {
    return this.vouchersService.findOne(id);
  }

  // ==========================================
  // POST /vouchers/:id/redeem  (User)
  // ==========================================

  /**
   * User đổi điểm lấy Voucher.
   * Được bảo vệ bằng PostgreSQL Transaction + Row-Level Lock chống double-spending.
   *
   * @param id - UUID của Voucher muốn đổi
   */
  @Post("vouchers/:id/redeem")
  @Roles("USER")
  @UseGuards(JwtAuthGuard, RolesGuard)
  @HttpCode(HttpStatus.OK)
  redeemVoucher(
    @Param("id", ParseUUIDPipe) id: string,
    @CurrentUser() currentUser: { userId: string },
  ) {
    return this.vouchersService.redeemVoucher(id, currentUser.userId);
  }

  // ==========================================
  // POST /merchants/vouchers  (Merchant)
  // ==========================================

  /**
   * Merchant tạo Voucher mới với mức điểm và số lượng tự đặt.
   * remaining_quantity khởi tạo bằng total_quantity.
   */
  @Post("merchants/vouchers")
  @Roles("MERCHANT")
  @UseGuards(JwtAuthGuard, RolesGuard)
  createVoucher(
    @CurrentUser() currentUser: { userId: string },
    @Body() dto: CreateVoucherDto,
  ) {
    return this.vouchersService.createVoucher(currentUser.userId, dto);
  }

  // ==========================================
  // POST /points/use-voucher  (Merchant)
  // ==========================================

  /**
   * Merchant quét barcode voucher để xác nhận khách đã dùng.
   * Chuyển trạng thái UserVoucher: ACTIVE → USED.
   * Có kiểm tra ownership (chỉ Merchant chủ voucher mới quét được).
   */
  @Post("points/use-voucher")
  @Roles("MERCHANT")
  @UseGuards(JwtAuthGuard, RolesGuard)
  @HttpCode(HttpStatus.OK)
  useVoucher(
    @CurrentUser() currentUser: { userId: string },
    @Body() dto: UseVoucherDto,
  ) {
    return this.vouchersService.useVoucher(currentUser.userId, dto);
  }
}
