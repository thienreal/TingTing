/**
 * @file        roles.decorator.ts
 * @module      AuthModule
 * @description Custom decorator để gắn metadata về role yêu cầu cho route.
 *
 * @responsibility
 *   - Đặt metadata 'roles' lên route handler để RolesGuard đọc và kiểm tra
 *
 * @dependencies
 *   - @nestjs/common (SetMetadata)
 *
 * @todo
 *   - [ ] (Không cần thêm gì)
 */

import { SetMetadata } from "@nestjs/common";

export type Role = "USER" | "MERCHANT";

/** Key metadata dùng để lưu roles trên route handler */
export const ROLES_KEY = "roles";

/**
 * Decorator khai báo role(s) được phép truy cập route.
 *
 * Ví dụ dùng:
 * ```typescript
 * @Roles('MERCHANT')
 * @UseGuards(JwtAuthGuard, RolesGuard)
 * @Post('earn')
 * earnPoints() { ... }
 * ```
 */
export const Roles = (...roles: Role[]) => SetMetadata(ROLES_KEY, roles);
