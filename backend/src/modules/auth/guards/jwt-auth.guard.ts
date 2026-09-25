/**
 * @file        jwt-auth.guard.ts
 * @module      AuthModule
 * @description Guard bảo vệ route — yêu cầu JWT hợp lệ mới được truy cập.
 *
 * @responsibility
 *   - Chặn request không có hoặc có JWT không hợp lệ/hết hạn
 *   - Gắn thông tin user vào request.user sau khi xác thực thành công
 *
 * @dependencies
 *   - @nestjs/passport (AuthGuard)
 *   - JwtStrategy
 *
 * @todo
 *   - [ ] (Không cần thêm gì — guard này đơn giản và đã đủ)
 */

import { Injectable } from "@nestjs/common";
import { AuthGuard } from "@nestjs/passport";

/**
 * Guard JWT chung — dùng cho mọi route cần đăng nhập
 * (cả User lẫn Merchant, sau đó dùng RolesGuard để phân quyền tiếp).
 *
 * Cách dùng:
 * ```typescript
 * @UseGuards(JwtAuthGuard)
 * @Get('profile')
 * getProfile(@Request() req) { return req.user; }
 * ```
 */
@Injectable()
export class JwtAuthGuard extends AuthGuard("jwt") {}
