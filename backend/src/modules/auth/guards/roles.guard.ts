/**
 * @file        roles.guard.ts
 * @module      AuthModule
 * @description Guard phân quyền theo role (RBAC).
 *   Dùng SAU JwtAuthGuard để kiểm tra role của user đã xác thực.
 *
 * @responsibility
 *   - Đọc metadata 'roles' từ route handler
 *   - So sánh với role trong JWT payload (req.user.role)
 *   - Từ chối (403 Forbidden) nếu role không khớp
 *
 * @dependencies
 *   - @nestjs/common (Reflector)
 *   - roles.decorator.ts (ROLES_KEY)
 *
 * @todo
 *   - [ ] (Không cần thêm gì)
 */

import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
} from "@nestjs/common";
import { Reflector } from "@nestjs/core";
import { ROLES_KEY, Role } from "../decorators/roles.decorator";

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  /**
   * Kiểm tra xem user có role phù hợp để truy cập route không.
   *
   * Nếu route không khai báo @Roles(...), cho phép tất cả (fallback = true).
   * Nếu route có @Roles(...), chỉ user có role nằm trong danh sách mới được vào.
   *
   * @param context - Execution context của request hiện tại
   * @returns true nếu được phép, throw ForbiddenException nếu không
   */
  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<Role[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    // Nếu route không đặt @Roles, không cần kiểm tra role
    if (!requiredRoles || requiredRoles.length === 0) {
      return true;
    }

    const { user } = context.switchToHttp().getRequest();

    const hasRole = requiredRoles.includes(user?.role);
    if (!hasRole) {
      throw new ForbiddenException(
        `Chỉ ${requiredRoles.join(" hoặc ")} mới có quyền thực hiện hành động này`,
      );
    }

    return true;
  }
}
