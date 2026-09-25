/**
 * @file        merchants.module.ts
 * @module      MerchantsModule
 * @description Module quản lý dữ liệu và chức năng của Merchant.
 *
 * @responsibility
 *   - Khai báo MerchantsController, MerchantsService
 *   - Đóng gói các chức năng liên quan đến tài khoản doanh nghiệp
 */

import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { MerchantsController } from "./merchants.controller";
import { MerchantsService } from "./merchants.service";
import { Merchant } from "./entities/merchant.entity";
import { Transaction } from "../transactions/entities/transaction.entity";
import { Voucher } from "../vouchers/entities/voucher.entity";
import { UserVoucher } from "../user-vouchers/entities/user-voucher.entity";
import { AuthModule } from "../auth/auth.module";

@Module({
  imports: [
    TypeOrmModule.forFeature([Merchant, Transaction, Voucher, UserVoucher]),
    AuthModule,
  ],
  controllers: [MerchantsController],
  providers: [MerchantsService],
  exports: [MerchantsService],
})
export class MerchantsModule {}
