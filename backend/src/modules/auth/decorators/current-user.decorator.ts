/**
 * @file        current-user.decorator.ts
 * @module      AuthModule
 * @description Custom decorator để extract thông tin user hiện tại từ request.
 *
 * @responsibility
 *   - Cung cấp shortcut lấy req.user đã được JwtStrategy điền vào
 *
 * @dependencies
 *   - @nestjs/common (createParamDecorator)
 *
 * @todo
 *   - [ ] (Không cần thêm gì)
 */

import { createParamDecorator, ExecutionContext } from "@nestjs/common";

/**
 * Lấy thông tin user đang đăng nhập từ JWT payload (đã được JwtStrategy validate).
 *
 * Ví dụ dùng trong Controller:
 * ```typescript
 * @Get('me')
 * @UseGuards(JwtAuthGuard)
 * getMe(@CurrentUser() user: JwtPayload) {
 *   return user; // { userId, role, phone/email }
 * }
 * ```
 */
export const CurrentUser = createParamDecorator(
  (data: unknown, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    return request.user;
  },
);
