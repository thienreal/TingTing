/**
 * @file        auth.module.ts
 * @module      AuthModule
 * @description Module xác thực — kết nối tất cả các thành phần Auth:
 *   Controller, Service, Strategy, Guards và JWT configuration.
 *
 * @responsibility
 *   - Import và cấu hình JwtModule với secret/expiry từ biến môi trường
 *   - Khai báo JwtStrategy để Passport biết cách xác thực token
 *   - Export JwtAuthGuard, RolesGuard để các Module khác dùng lại
 *
 * @dependencies
 *   - @nestjs/jwt (JwtModule)
 *   - @nestjs/passport (PassportModule)
 *   - TypeOrmModule (User, Merchant entities)
 *   - ConfigModule (đọc JWT_SECRET từ .env)
 *
 * @todo
 *   - [ ] Thêm JwtModule.registerAsync để dùng ConfigService bất đồng bộ
 *         (hiện tại dùng register đồng bộ với process.env vì ConfigModule.forRoot isGlobal)
 */

import { Module } from "@nestjs/common";
import { JwtModule } from "@nestjs/jwt";
import { PassportModule } from "@nestjs/passport";
import { TypeOrmModule } from "@nestjs/typeorm";
import { ConfigModule, ConfigService } from "@nestjs/config";

import { AuthController } from "./auth.controller";
import { AuthService } from "./auth.service";
import { JwtStrategy } from "./strategies/jwt.strategy";
import { JwtAuthGuard } from "./guards/jwt-auth.guard";
import { RolesGuard } from "./guards/roles.guard";
import { User } from "../users/entities/user.entity";
import { Merchant } from "../merchants/entities/merchant.entity";

@Module({
  imports: [
    // PassportModule mặc định dùng strategy 'jwt'
    PassportModule.register({ defaultStrategy: "jwt" }),

    // Cấu hình JwtModule bất đồng bộ để đọc secret từ ConfigService
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        // Đọc từ .env — không hardcode secret
        secret: configService.get<string>("JWT_SECRET"),
        signOptions: {
          expiresIn: configService.get<string>("JWT_EXPIRES_IN") || "7d",
        },
      }),
    }),

    // Cần TypeORM để AuthService truy vấn User và Merchant
    TypeOrmModule.forFeature([User, Merchant]),
  ],
  controllers: [AuthController],
  providers: [
    AuthService,
    JwtStrategy, // Passport cần Provider này để biết cách verify token
    JwtAuthGuard,
    RolesGuard,
  ],
  // Export guards và strategy để các Module khác (Users, Vouchers...) dùng lại
  exports: [AuthService, JwtAuthGuard, RolesGuard, PassportModule, JwtModule],
})
export class AuthModule {}
