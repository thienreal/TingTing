/**
 * @file        jwt.strategy.ts
 * @module      AuthModule
 * @description Passport Strategy xác thực JWT cho người dùng (User - B2C).
 *   Được dùng cho guard `JwtAuthGuard` bảo vệ các route cần đăng nhập.
 *
 * @responsibility
 *   - Giải mã JWT Access Token từ Authorization header (Bearer scheme)
 *   - Trả về payload chứa userId và role để các handler sử dụng
 *
 * @dependencies
 *   - @nestjs/passport, passport-jwt
 *   - JWT_SECRET từ biến môi trường (backend/.env)
 *
 * @todo
 *   - [ ] Thêm blacklist token (Redis) khi triển khai logout
 */

import { Injectable } from "@nestjs/common";
import { PassportStrategy } from "@nestjs/passport";
import { ExtractJwt, Strategy } from "passport-jwt";
import { ConfigService } from "@nestjs/config";

export interface JwtPayload {
  sub: string; // UUID của user hoặc merchant
  role: "USER" | "MERCHANT";
  phone?: string; // Chỉ có khi role = USER
  email?: string; // Chỉ có khi role = MERCHANT
  iat?: number; // Issued at (tự động thêm bởi JWT)
  exp?: number; // Expiry (tự động thêm bởi JWT)
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy, "jwt") {
  constructor(private readonly configService: ConfigService) {
    super({
      // Lấy token từ Authorization: Bearer <token>
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      // JWT_SECRET đọc từ .env — không hardcode
      secretOrKey: configService.get<string>("JWT_SECRET"),
    });
  }

  /**
   * Được gọi sau khi JWT hợp lệ và giải mã thành công.
   * Giá trị trả về sẽ được gắn vào request.user.
   *
   * @param payload - Payload đã giải mã từ JWT
   * @returns Object chứa thông tin định danh người dùng
   */
  async validate(payload: JwtPayload) {
    return {
      userId: payload.sub,
      role: payload.role,
      phone: payload.phone,
      email: payload.email,
    };
  }
}
