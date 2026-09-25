import { Module } from "@nestjs/common";
import { AppController } from "./app.controller";
import { AppService } from "./app.service";
import { ConfigModule } from "@nestjs/config";
import { TypeOrmModule } from "@nestjs/typeorm";
import { typeOrmConfig } from "./config/database.config";
import { AuthModule } from "./modules/auth/auth.module";
import { UsersModule } from "./modules/users/users.module";
import { VouchersModule } from "./modules/vouchers/vouchers.module";
import { MerchantsModule } from "./modules/merchants/merchants.module";

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    TypeOrmModule.forRoot(typeOrmConfig),
    // ==========================================
    // FEATURE MODULES
    // ==========================================
    AuthModule, // Xác thực: OTP (User), email/password (Merchant), JWT, RBAC
    UsersModule, // Users & Points: profile, lịch sử giao dịch, cộng điểm, số dư
    VouchersModule, // Vouchers: danh sách, đổi điểm (chống double-spending), tạo, dùng
    MerchantsModule, // Merchants: thông tin, báo cáo thống kê giao dịch/voucher
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
