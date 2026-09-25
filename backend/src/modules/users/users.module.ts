/**
 * @file        users.module.ts
 * @module      UsersModule
 * @description Module quản lý Users và Points — kết nối Controller, Service,
 *   và các Entity cần thiết (User, Transaction, Merchant).
 *
 * @responsibility
 *   - Khai báo UsersController và UsersService
 *   - Import AuthModule để dùng JwtAuthGuard và RolesGuard
 *   - Cung cấp DataSource cho QueryRunner (Row-Level Lock)
 *
 * @dependencies
 *   - AuthModule (guards, decorators)
 *   - TypeOrmModule (User, Transaction, Merchant entities)
 *
 * @todo
 *   - [ ] (Không cần thêm gì cho MVP)
 */

import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";

import { UsersController } from "./users.controller";
import { UsersService } from "./users.service";
import { User } from "./entities/user.entity";
import { Transaction } from "../transactions/entities/transaction.entity";
import { Merchant } from "../merchants/entities/merchant.entity";
import { AuthModule } from "../auth/auth.module";

@Module({
  imports: [
    // Cần User để query profile và cập nhật điểm
    // Cần Transaction để lưu lịch sử giao dịch
    // Cần Merchant để xác thực merchant đang cộng điểm
    TypeOrmModule.forFeature([User, Transaction, Merchant]),

    // Import AuthModule để dùng JwtAuthGuard, RolesGuard đã được export
    AuthModule,
  ],
  controllers: [UsersController],
  providers: [UsersService],
  // Export UsersService để các module khác (Vouchers) có thể query User nếu cần
  exports: [UsersService],
})
export class UsersModule {}
