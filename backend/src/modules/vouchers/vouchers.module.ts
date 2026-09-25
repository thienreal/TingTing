/**
 * @file        vouchers.module.ts
 * @module      VouchersModule
 * @description Module Vouchers — kết nối Controller, Service và các Entity.
 *
 * @responsibility
 *   - Khai báo VouchersController, VouchersService
 *   - Import AuthModule để dùng JwtAuthGuard, RolesGuard
 *   - Cung cấp DataSource cho QueryRunner (chống double-spending)
 *
 * @dependencies
 *   - AuthModule (guards)
 *   - TypeOrmModule (Voucher, UserVoucher, User, Merchant)
 *
 * @todo
 *   - [ ] (Không cần thêm gì cho MVP)
 */

import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";

import { VouchersController } from "./vouchers.controller";
import { VouchersService } from "./vouchers.service";
import { Voucher } from "./entities/voucher.entity";
import { UserVoucher } from "../user-vouchers/entities/user-voucher.entity";
import { User } from "../users/entities/user.entity";
import { Merchant } from "../merchants/entities/merchant.entity";
import { AuthModule } from "../auth/auth.module";

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Voucher, // Quản lý danh sách và tồn kho voucher
      UserVoucher, // Theo dõi voucher User đang sở hữu
      User, // Trừ điểm khi User đổi voucher
      Merchant, // Xác thực merchant khi tạo/dùng voucher
    ]),
    AuthModule,
  ],
  controllers: [VouchersController],
  providers: [VouchersService],
  exports: [VouchersService],
})
export class VouchersModule {}
