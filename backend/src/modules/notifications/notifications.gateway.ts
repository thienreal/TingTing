/**
 * @file        notifications.gateway.ts
 * @module      NotificationsModule
 * @description WebSocket Gateway xử lý kết nối real-time giữa Backend và User App.
 *
 * @responsibility
 *   - Lắng nghe sự kiện `join` từ client để đăng ký userId → socketId vào bộ nhớ
 *   - Gửi thông báo riêng tư (unicast) `points_earned` đến đúng User khi được cộng điểm
 *   - Quản lý vòng đời socket: connect / disconnect
 *
 * @dependencies
 *   - @nestjs/websockets (WebSocketGateway, WebSocketServer, SubscribeMessage)
 *   - socket.io (Server, Socket) — chạy trên WEBSOCKET_PORT (mặc định 3001)
 *
 * @todo
 *   - [ ] Xác thực JWT trong handshake thay vì nhận userId từ client (bảo mật hơn cho Production)
 *   - [ ] Lưu userId → socketId vào Redis để hỗ trợ horizontal scaling (nhiều server instance)
 */

import { Logger } from '@nestjs/common';
import {
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

// ==========================================
// KIỂU DỮ LIỆU
// ==========================================

/** Payload gửi xuống client khi user được cộng điểm thành công */
export interface PointsEarnedPayload {
  /** Số điểm vừa được cộng */
  points_earned: number;
  /** Tổng điểm tích lũy sau khi cộng */
  new_total_points: number;
  /** Hạng thành viên mới (STANDARD | SILVER | GOLD | PLATINUM) */
  new_membership_tier: string;
  /** Có lên hạng hay không */
  tier_upgraded: boolean;
  /** Tên cửa hàng đã cộng điểm (để hiển thị trên SnackBar) */
  merchant_name: string;
}

// ==========================================
// GATEWAY CONFIG
// Đọc WEBSOCKET_PORT từ biến môi trường, mặc định 3001 nếu chưa cấu hình.
// cors origin '*' phù hợp cho môi trường Dev/LAN. Production nên giới hạn origin.
// ==========================================
@WebSocketGateway(parseInt(process.env.WEBSOCKET_PORT || '3001', 10), {
  cors: {
    origin: '*',
  },
  transports: ['websocket', 'polling'],
})
export class NotificationsGateway
  implements OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer()
  private readonly server: Server;

  private readonly logger = new Logger(NotificationsGateway.name);

  // ==========================================
  // BỘ NHỚ: userId → socketId
  // Lưu tạm trong RAM — đủ dùng cho MVP single-server.
  // Cần Redis nếu scale lên nhiều instance.
  // ==========================================
  private readonly userSocketMap = new Map<string, string>();

  // ==========================================
  // VÒNG ĐỜI SOCKET
  // ==========================================

  /**
   * Gọi tự động khi một client mới kết nối.
   * Chỉ log, chưa biết userId — phải đợi client emit `join`.
   */
  handleConnection(client: Socket): void {
    this.logger.log(`[WS] Client kết nối: socketId=${client.id}`);
  }

  /**
   * Gọi tự động khi client ngắt kết nối (đóng app, mất mạng...).
   * Dọn dẹp entry trong userSocketMap để tránh rò rỉ bộ nhớ.
   */
  handleDisconnect(client: Socket): void {
    // Tìm và xóa userId tương ứng với socket vừa disconnect
    for (const [userId, socketId] of this.userSocketMap.entries()) {
      if (socketId === client.id) {
        this.userSocketMap.delete(userId);
        this.logger.log(
          `[WS] Client ngắt kết nối: socketId=${client.id}, userId=${userId}`,
        );
        return;
      }
    }
    this.logger.log(`[WS] Client ngắt kết nối (chưa join): socketId=${client.id}`);
  }

  // ==========================================
  // SỰ KIỆN: join
  // Client emit ngay sau khi kết nối để đăng ký userId của mình.
  // ==========================================

  /**
   * Nhận sự kiện `join` từ User App để ánh xạ userId → socketId.
   * Sau khi join thành công, server emit `join_ack` để confirm.
   *
   * @param client - Socket của client gửi sự kiện
   * @param data   - Object chứa userId (UUID của user đang đăng nhập)
   */
  @SubscribeMessage('join')
  handleJoin(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { userId: string },
  ): void {
    const { userId } = data;
    if (!userId) {
      this.logger.warn(`[WS] Join thiếu userId: socketId=${client.id}`);
      return;
    }

    // Ghi đè nếu user đã join trước đó (ví dụ: reconnect)
    this.userSocketMap.set(userId, client.id);
    this.logger.log(
      `[WS] User đăng ký nhận thông báo: userId=${userId}, socketId=${client.id}`,
    );

    // Xác nhận join thành công về phía client
    client.emit('join_ack', { success: true, userId });
  }

  // ==========================================
  // PHÁT SỰ KIỆN: points_earned (gọi từ UsersService)
  // ==========================================

  /**
   * Phát sự kiện `points_earned` đến đúng socket của User vừa được cộng điểm.
   * Được gọi từ UsersService sau khi commit transaction thành công.
   *
   * Nếu user không có socket đang kết nối (app đang đóng),
   * sự kiện sẽ được bỏ qua (MVP không cần persist notification).
   *
   * @param userId  - UUID của user được cộng điểm
   * @param payload - Chi tiết điểm và thông tin cửa hàng để hiển thị
   */
  notifyPointsEarned(userId: string, payload: PointsEarnedPayload): void {
    const socketId = this.userSocketMap.get(userId);

    if (!socketId) {
      // User không online — bỏ qua (MVP không lưu pending notification)
      this.logger.debug(
        `[WS] User ${userId} không online, bỏ qua notification`,
      );
      return;
    }

    // Emit thẳng đến socket của user đó (unicast)
    this.server.to(socketId).emit('points_earned', payload);
    this.logger.log(
      `[WS] Đã gửi points_earned → userId=${userId} ` +
        `(+${payload.points_earned} điểm, tổng: ${payload.new_total_points})`,
    );
  }
}
